# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Airspace
  # This mix-in allows for classes to be composed of a Metadata instance
  module HasMetadata
    extend Forwardable

    attr_reader :metadata

    def_delegators  :metadata,
                    :chunk_count,
                    :chunker,
                    :expires_in_seconds,
                    :page_count,
                    :pages_per_chunk
  end
end
