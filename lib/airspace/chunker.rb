# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Airspace
  # Chunking here is defined as: taking an array of pages and grouping them into groups of pages
  # (chunks) in order to find a middle-ground of server-side page and entire dataset fetches.
  class Chunker
    Location = Struct.new(:chunk_index, :page_index)
    Chunk    = Struct.new(:chunk_index, :page_index_start, :page_index_end)

    attr_reader :pages_per_chunk

    def initialize(pages_per_chunk)
      raise ArgumentError unless pages_per_chunk.positive?

      @pages_per_chunk = pages_per_chunk
    end

    def count(page_total)
      (page_total / pages_per_chunk.to_f).ceil
    end

    def each(page_total)
      return enum_for(:each, page_total) unless block_given?

      (0...count(page_total)).each do |chunk_index|
        page_index_start = chunk_index * pages_per_chunk
        page_index_end   = page_index_start + pages_per_chunk - 1

        yield Chunk.new(chunk_index, page_index_start, page_index_end)
      end
    end

    def locate(index)
      chunk_index = (index / pages_per_chunk.to_f).floor
      page_index = index % pages_per_chunk

      Location.new(chunk_index, page_index)
    end
  end
end
