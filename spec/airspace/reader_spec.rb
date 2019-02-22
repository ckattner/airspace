# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require './spec/spec_helper'

describe ::Airspace::Reader do
  let(:client) { Redis.new }

  let(:id) { 'reader-test-set' }

  let(:options) { { prefix: TEST_PREFIX } }

  let(:reader) { ::Airspace.get(client, id, options: options) }

  subject { reader }

  context 'with no pages' do
    before(:each) do
      ::Airspace.set(client, id: id, options: options)
    end

    describe '#page' do
      it 'should return empty array when page_count is 0' do
        expect(subject.page(1)).to eq([])
      end

      it 'should return empty array when number <= 0' do
        expect(subject.page(-1)).to eq([])
      end
    end

    describe '#pages' do
      it 'should return empty array when page_count is 0' do
        expect(subject.pages).to eq([])
      end
    end
  end

  context 'with pages' do
    let(:pages) do
      [
        [
          { 'id' => 1, 'name' => 'Matt' }
        ]
      ]
    end

    before(:each) do
      ::Airspace.set(client, id: id, options: options, pages: pages)
    end

    describe '#page' do
      it 'should return array of rows when number <= page_count' do
        expect(subject.page(1)).to eq(pages[0])
      end

      it 'should return empty array when number > page_count' do
        expect(subject.page(2)).to eq([])
      end

      it 'should return empty array when number <= 0' do
        expect(subject.page(-1)).to eq([])
      end
    end

    describe '#page' do
      it 'should return array of pages when page_count > 0' do
        expect(subject.pages).to eq(pages)
      end
    end
  end
end
