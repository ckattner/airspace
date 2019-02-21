# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Airspace
  # This is the main class that knows how to fetch and interpret the dataset.
  # It is optimized for chunking/paging and allows you to only pull back specific
  # pages (if desired.)
  class Reader
    extend Forwardable
    extend ::Airspace::InfoKeys
    include ::Airspace::HasMetadata

    class << self
      def find_by_id(client, id, options: {})
        key        = ::Airspace::Key.new(id, prefix: options[:prefix])
        serializer = options[:serializer] || ::Airspace::Serializer.new
        hash       = fetch_and_transform(client, key, serializer)
        return nil unless hash

        metadata_args = hash[METADATA_KEY].map { |k, v| [k.to_sym, v] }.to_h

        new(
          client,
          data: hash[DATA_KEY],
          key: key,
          metadata: ::Airspace::Metadata.new(metadata_args),
          serializer: serializer
        )
      end

      private

      def fetch_and_transform(client, key, serializer)
        hash = ::Airspace::Store.new(client).retrieve(key)
        return nil unless hash

        {}.tap do |h|
          h[DATA_KEY] = serializer.deserialize_data(hash[DATA_KEY])
          h[METADATA_KEY] = serializer.deserialize_metadata(hash[METADATA_KEY])
        end
      end
    end

    attr_reader :client,
                :data,
                :key,
                :metadata,
                :serializer

    def_delegators :key, :id

    def initialize(client, data:, key:, metadata:, serializer:)
      @client     = client
      @key        = key
      @data       = data
      @metadata   = metadata
      @serializer = serializer

      freeze
    end

    def pages
      store.chunks(key, chunk_count).map do |chunk|
        chunk.map { |r| serializer.deserialize_row(r) }
      end
    end

    def page(number)
      page_index  = number - 1
      location    = chunker.locate(page_index)
      chunk       = store.chunk(key, location.chunk_index)

      chunk[location.page_index].map { |r| serializer.deserialize_row(r) }
    end

    def delete
      store.delete(key, page_count)
    end

    private

    def store
      ::Airspace::Store.new(client)
    end
  end
end
