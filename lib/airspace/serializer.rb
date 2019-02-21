# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Airspace
  # This class dictates how data is stored and retrieved.  You can subclass this and
  # change its implementation that suits your overall data/space requirements.
  class Serializer
    def serialize_data(obj)
      json_serialize(obj)
    end

    def deserialize_data(json)
      json_deserialize(json)
    end

    def serialize_row(obj)
      json_serialize(obj)
    end

    def deserialize_row(json)
      json_deserialize(json)
    end

    def serialize_metadata(obj)
      json_serialize(obj)
    end

    def deserialize_metadata(json)
      json_deserialize(json)
    end

    private

    def json_deserialize(json)
      return nil unless json

      JSON.parse(json)
    end

    def json_serialize(obj)
      obj.to_json
    end
  end
end
