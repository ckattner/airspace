# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'forwardable'
require 'json'
require 'securerandom'
require 'time'

require_relative 'key'
require_relative 'info_keys'
require_relative 'chunker'
require_relative 'metadata'
require_relative 'has_metadata'
require_relative 'dataset'
require_relative 'serializer'
require_relative 'reader'
require_relative 'store'

# Top-level namespace for primary public API.
module Airspace
  class << self
    def set(client, id: nil, data: {}, pages: [], options: {})
      ::Airspace::Dataset.new(
        client,
        id: id,
        data: data,
        pages: pages,
        options: options
      ).save.id
    end

    def get(client, id, options: {})
      ::Airspace::Reader.find_by_id(client, id, options: options)
    end

    def del(client, id, options: {})
      reader = get(client, id, options: options)

      return false unless reader

      reader.delete
    end
  end
end
