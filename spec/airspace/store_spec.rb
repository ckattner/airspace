# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require './spec/spec_helper'

# This is mainly to ensure CI has a proper Redis installation and instance.
describe ::Airspace::Store do
  let(:client) { Redis.new }

  describe 'initialization' do
    it 'should raise ArgumentError with a null client' do
      expect { ::Airspace::Store.new(nil) }.to raise_error(ArgumentError)
    end
  end
end
