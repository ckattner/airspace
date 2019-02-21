# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Airspace
  # This class understands how to build keys and subkeys for storing data inside Redis.
  class Key
    SEPARATOR_CHAR = ':'

    private_constant :SEPARATOR_CHAR

    attr_reader :id, :prefix

    def initialize(id, prefix: '')
      @id     = id.to_s
      @prefix = prefix.to_s
    end

    def root
      return id if prefix.empty?

      [prefix, id].join(SEPARATOR_CHAR)
    end
    alias to_s root

    def chunk(index)
      [root, index].join(SEPARATOR_CHAR)
    end
  end
end
