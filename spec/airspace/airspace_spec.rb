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
    json_serialize([obj['first'], obj['last']])
  end

  def deserialize_data(json)
    array = json_deserialize(json)

    {
      'first' => array[0],
      'last' => array[1]
    }
  end

  def serialize_row(obj)
    json_serialize([obj['id'], obj['name']])
  end

  def deserialize_row(json)
    array = json_deserialize(json)

    {
      'id' => array[0],
      'name' => array[1]
    }
  end
end

# This is mainly to ensure CI has a proper Redis installation and instance.
describe ::Airspace do
  let(:client) { Redis.new }

  let(:data) do
    {
      'first' => 'Matt',
      'last' => 'Rizzo'
    }
  end

  let(:pages) do
    [
      [
        { 'id' => 1, 'name' => 'Iron Man' },
        { 'id' => 2, 'name' => 'Hulk' }
      ],
      [
        { 'id' => 3, 'name' => 'Thor' },
        { 'id' => 4, 'name' => 'Spiderman' }
      ],
      [
        { 'id' => 1, 'name' => 'Captain America' }
      ]
    ]
  end

  describe '#get, #set, #del' do
    it 'should use passed in ID' do
      id = 'marvel'
      options = { prefix: TEST_PREFIX }

      ::Airspace.set(client, data: data, id: id, pages: pages, options: options)

      actual_reader = ::Airspace.get(client, id, options: options)
      expect(actual_reader.data).to eq(data)
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
      expect(actual_reader.data).to eq(data)
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
      expect(actual_reader.data).to eq(data)
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
  end
end
