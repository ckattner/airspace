# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require './spec/spec_helper'

describe ::Airspace::Chunker do
  subject { ::Airspace::Chunker }

  describe 'initialization' do
    it 'should raise ArgumentError with a negative pages_per_chunk' do
      expect { subject.new(-1) }.to raise_error(ArgumentError)
    end

    it 'should raise ArgumentError with a zero pages_per_chunk' do
      expect { subject.new(0) }.to raise_error(ArgumentError)
    end
  end

  describe '#count with pages_per_chunk = 5' do
    it { expect(subject.new(5).count(0)).to eq(0) }
    it { expect(subject.new(5).count(1)).to eq(1) }
    it { expect(subject.new(5).count(2)).to eq(1) }
    it { expect(subject.new(5).count(3)).to eq(1) }
    it { expect(subject.new(5).count(4)).to eq(1) }
    it { expect(subject.new(5).count(5)).to eq(1) }
    it { expect(subject.new(5).count(6)).to eq(2) }
  end

  describe '#count with pages_per_chunk = 1' do
    let(:pages_per_chunk) { 1 }
    it { expect(subject.new(pages_per_chunk).count(0)).to eq(0) }
    it { expect(subject.new(pages_per_chunk).count(1)).to eq(1) }
    it { expect(subject.new(pages_per_chunk).count(2)).to eq(2) }
    it { expect(subject.new(pages_per_chunk).count(3)).to eq(3) }
    it { expect(subject.new(pages_per_chunk).count(4)).to eq(4) }
    it { expect(subject.new(pages_per_chunk).count(5)).to eq(5) }
    it { expect(subject.new(pages_per_chunk).count(6)).to eq(6) }
  end

  describe '#count with pages_per_chunk = 9' do
    let(:pages_per_chunk) { 9 }
    it { expect(subject.new(pages_per_chunk).count(0)).to eq(0) }
    it { expect(subject.new(pages_per_chunk).count(1)).to eq(1) }
    it { expect(subject.new(pages_per_chunk).count(2)).to eq(1) }
    it { expect(subject.new(pages_per_chunk).count(3)).to eq(1) }
    it { expect(subject.new(pages_per_chunk).count(4)).to eq(1) }
    it { expect(subject.new(pages_per_chunk).count(5)).to eq(1) }
    it { expect(subject.new(pages_per_chunk).count(6)).to eq(1) }
  end

  it '#each with page_size = 0' do
    chunker = subject.new(5)

    actual = chunker.each(0).with_object([]) { |chunk, array| array << chunk }

    expected = []

    expect(actual).to eq(expected)
  end

  it '#each with page_size = 6' do
    chunker = subject.new(5)

    actual = chunker.each(6).with_object([]) { |chunk, array| array << chunk }

    expected = [
      ::Airspace::Chunker::Chunk.new(0, 0, 4),
      ::Airspace::Chunker::Chunk.new(1, 5, 9)
    ]

    expect(actual).to eq(expected)
  end

  it '#each with page_size = 13' do
    chunker = subject.new(5)

    actual = chunker.each(13).with_object([]) { |chunk, array| array << chunk }

    expected = [
      ::Airspace::Chunker::Chunk.new(0, 0, 4),
      ::Airspace::Chunker::Chunk.new(1, 5, 9),
      ::Airspace::Chunker::Chunk.new(2, 10, 14)
    ]

    expect(actual).to eq(expected)
  end

  describe '.locate' do
    it { expect(subject.new(5).locate(0)).to eq(::Airspace::Chunker::Location.new(0, 0)) }
    it { expect(subject.new(5).locate(1)).to eq(::Airspace::Chunker::Location.new(0, 1)) }
    it { expect(subject.new(5).locate(2)).to eq(::Airspace::Chunker::Location.new(0, 2)) }
    it { expect(subject.new(5).locate(3)).to eq(::Airspace::Chunker::Location.new(0, 3)) }
    it { expect(subject.new(5).locate(4)).to eq(::Airspace::Chunker::Location.new(0, 4)) }
    it { expect(subject.new(5).locate(5)).to eq(::Airspace::Chunker::Location.new(1, 0)) }
    it { expect(subject.new(5).locate(6)).to eq(::Airspace::Chunker::Location.new(1, 1)) }

    it 'should raise ArgumentError with a negative pages_per_chunk' do
      expect { subject.new(-1).locate(0) }.to raise_error(ArgumentError)
    end

    it 'should raise ArgumentError with a zero pages_per_chunk' do
      expect { subject.new(0).locate(0) }.to raise_error(ArgumentError)
    end
  end
end
