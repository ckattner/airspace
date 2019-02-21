# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Airspace
  # Metdata is 'data about a dataset.'  These are key pieces of information we need to store with
  # the data then later retrieve with the data.
  class Metadata
    DEFAULT_PAGES_PER_CHUNK = 5

    attr_reader :expires_in_seconds,
                :page_count,
                :pages_per_chunk

    def initialize(expires_in_seconds: nil, page_count: 0, pages_per_chunk: DEFAULT_PAGES_PER_CHUNK)
      @expires_in_seconds = expires_in_seconds ? expires_in_seconds.to_i : nil
      @page_count         = page_count.to_i
      @pages_per_chunk    = pages_per_chunk ? pages_per_chunk.to_i : DEFAULT_PAGES_PER_CHUNK

      freeze
    end

    def chunker
      ::Airspace::Chunker.new(pages_per_chunk)
    end

    def chunk_count
      chunker.count(page_count)
    end

    def as_json
      {
        expires_in_seconds: expires_in_seconds,
        page_count: page_count,
        pages_per_chunk: pages_per_chunk
      }
    end
  end
end
