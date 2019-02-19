# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require './spec/spec_helper'

# This is mainly to ensure CI has a proper Redis installation and instance.
describe ::Redis do
  let(:key) { airspace_test_key('name') }

  let(:value) { 'Frank Rizzo' }

  let(:client) { Redis.new }

  subject { client }

  it 'should set and get a key' do
    subject.set(key, value)
    value = subject.get(key)
    expect(value).to eq(value)
  end
end
