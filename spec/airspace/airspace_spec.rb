# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require './spec/spec_helper'

class CustomSerializer < ::Airspace::Serializer
  def serialize_data(obj)
    obj = obj.map { |k, v| [k.to_sym, v] }.to_h

    json_serialize(
      [
        obj[:movie_name],
        obj[:release_date].to_s,
        obj[:rating]
      ]
    )
  end

  def deserialize_data(json)
    array = json_deserialize(json)

    {
      movie_name: array[0],
      release_date: Date.parse(array[1]),
      rating: array[2]
    }
  end

  def serialize_row(obj)
    obj = obj.map { |k, v| [k.to_sym, v] }.to_h

    json_serialize([obj[:id], obj[:name]])
  end

  def deserialize_row(json)
    array = json_deserialize(json)

    {
      id: array[0],
      name: array[1]
    }
  end
end

# This is mainly to ensure CI has a proper Redis installation and instance.
describe ::Airspace do
  let(:client) { Redis.new }

  let(:data) do
    {
      'movie_name' => 'Avengers',
      'release_date' => Date.new(2012, 5, 5),
      'rating' => 'PG-13'
    }
  end

  let(:data_hash) do
    {
      'movie_name' => 'Avengers',
      'release_date' => '2012-05-05',
      'rating' => 'PG-13'
    }
  end

  let(:rows) do
    [
      { 'id' => 1, 'name' => 'Iron Man' },
      { 'id' => 2, 'name' => 'Hulk' },
      { 'id' => 3, 'name' => 'Thor' },
      { 'id' => 4, 'name' => 'Spiderman' },
      { 'id' => 5, 'name' => 'Captain America' }
    ]
  end

  let(:pages) do
    rows.each_slice(2).to_a
  end

  let(:symbolized_pages) do
    pages.map { |page| page.map { |row| row.map { |k, v| [k.to_sym, v] }.to_h } }
  end

  describe '#get, #set, #del' do
    it 'should use passed in ID' do
      id = 'marvel'
      options = { prefix: TEST_PREFIX }

      ::Airspace.set(client, data: data, id: id, pages: pages, options: options)

      actual_reader = ::Airspace.get(client, id, options: options)
      expect(actual_reader.data).to eq(data_hash)
      expect(actual_reader.page_count).to eq(pages.length)

      actual_pages = actual_reader.pages
      expect(actual_pages).to eq(pages)

      actual_page1 = actual_reader.page(1)
      expect(actual_page1).to eq(pages[0])

      actual_page2 = actual_reader.page(2)
      expect(actual_page2).to eq(pages[1])

      actual_page3 = actual_reader.page(3)
      expect(actual_page3).to eq(pages[2])

      deleted = ::Airspace.del(client, id, options: options)
      expect(deleted).to be true

      reader = ::Airspace.get(client, id, options: options)
      expect(reader).to be nil
    end

    it 'should auto-assign ID' do
      options = { prefix: TEST_PREFIX }
      id = ::Airspace.set(client, data: data, pages: pages, options: options)

      actual_reader = ::Airspace.get(client, id, options: options)
      expect(actual_reader.data).to eq(data_hash)
      expect(actual_reader.page_count).to eq(pages.length)

      actual_pages = actual_reader.pages
      expect(actual_pages).to eq(pages)

      actual_page1 = actual_reader.page(1)
      expect(actual_page1).to eq(pages[0])

      actual_page2 = actual_reader.page(2)
      expect(actual_page2).to eq(pages[1])

      actual_page3 = actual_reader.page(3)
      expect(actual_page3).to eq(pages[2])

      deleted = ::Airspace.del(client, id, options: options)
      expect(deleted).to be true

      reader = ::Airspace.get(client, id, options: options)
      expect(reader).to be nil
    end

    it 'should suppport custom serialization' do
      options = {
        prefix: TEST_PREFIX,
        serializer: CustomSerializer.new
      }

      id = ::Airspace.set(client, data: data, pages: pages, options: options)

      actual_reader = ::Airspace.get(client, id, options: options)
      expect(actual_reader.data).to eq(data.map { |k, v| [k.to_sym, v] }.to_h)
      expect(actual_reader.page_count).to eq(pages.length)

      actual_pages = actual_reader.pages
      expect(actual_pages).to eq(symbolized_pages)

      actual_page1 = actual_reader.page(1)
      expect(actual_page1).to eq(symbolized_pages[0])

      actual_page2 = actual_reader.page(2)
      expect(actual_page2).to eq(symbolized_pages[1])

      actual_page3 = actual_reader.page(3)
      expect(actual_page3).to eq(symbolized_pages[2])

      deleted = ::Airspace.del(client, id, options: options)
      expect(deleted).to be true

      reader = ::Airspace.get(client, id, options: options)
      expect(reader).to be nil
    end
  end
end
