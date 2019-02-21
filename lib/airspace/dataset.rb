# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Airspace
  # This is the main input class that can persist data.
  class Dataset
    include ::Airspace::InfoKeys
    include ::Airspace::HasMetadata

    attr_reader :client,
                :data,
                :id,
                :pages,
                :prefix,
                :serializer

    def initialize(client, id: nil, data: {}, pages: [], options: {})
      raise ArgumentError, 'client is required' unless client

      @client     = client
      @data       = data || {}
      @id         = id || SecureRandom.uuid
      @pages      = pages || []
      @prefix     = options[:prefix].to_s
      @serializer = options[:serializer] || ::Airspace::Serializer.new

      @metadata = ::Airspace::Metadata.new(
        expires_in_seconds: options[:expires_in_seconds],
        page_count: pages.length,
        pages_per_chunk: options[:pages_per_chunk]
      )

      freeze
    end

    def save
      store.persist(key, info_hash, chunks, expires_in_seconds)

      self
    end

    private

    def info_hash
      {}.tap do |hash|
        hash[DATA_KEY]      = serializer.serialize_data(data)
        hash[METADATA_KEY]  = serializer.serialize_metadata(metadata.as_json)
      end
    end

    def chunks
      chunks = []

      chunker.each(page_count) do |chunk|
        chunk_data = pages[chunk.page_index_start..chunk.page_index_end]

        chunks << chunk_data.map do |page|
          page.map { |row| serializer.serialize_row(row) }
        end
      end

      chunks
    end

    def store
      ::Airspace::Store.new(client)
    end

    def key
      ::Airspace::Key.new(id, prefix: prefix)
    end
  end
end
