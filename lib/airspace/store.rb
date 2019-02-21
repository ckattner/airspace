# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Airspace
  # The Store is the data access layer that knows how to persist and retrieve all data.
  # There really should never be a need to interact directly with the store, it merely
  # acts as an intermediary between the Redis client and the Dataset/Reader.
  class Store
    attr_reader :client

    def initialize(client)
      raise ArgumentError unless client

      @client = client
    end

    def exist?(key)
      client.exists(key.root)
    end

    def persist(key, info_hash, chunks, expires_in_seconds)
      options = make_options(expires_in_seconds)

      multi_pipeline do
        client.set(key.root, info_hash.to_json, options)

        chunks.each_with_index do |chunk, index|
          chunk_key = key.chunk(index)
          client.set(chunk_key, chunk.to_json, options)
        end
      end

      nil
    end

    def retrieve(key)
      return nil unless exist?(key)

      data = client.get(key)

      JSON.parse(data)
    end

    def delete(key, chunk_count)
      return false unless exist?(key)

      multi_pipeline do
        client.del(key.root)

        (0...chunk_count).each do |index|
          chunk_key = key.chunk(index)
          client.del(chunk_key)
        end
      end

      true
    end

    def chunks(key, chunk_count)
      futures     = chunk_futures(key, chunk_count)
      all_chunks  = []

      futures.each do |chunk_future|
        cached_chunk = chunk_future.value
        all_chunks += JSON.parse(cached_chunk)
      end

      all_chunks
    end

    def chunk(key, chunk_index)
      chunk_key     = key.chunk(chunk_index)
      cached_chunk  = client.get(chunk_key)

      return [] unless cached_chunk

      JSON.parse(cached_chunk)
    end

    private

    def multi_pipeline
      client.multi do
        client.pipelined do
          yield
        end
      end
    end

    def make_options(expires_in_seconds)
      {}.tap do |o|
        o[:ex] = expires_in_seconds if expires_in_seconds
      end
    end

    def chunk_futures(key, chunk_count)
      futures = []

      client.pipelined do
        (0...chunk_count).each do |index|
          chunk_key = key.chunk(index)
          futures << client.get(chunk_key)
        end
      end

      futures
    end
  end
end
