# frozen_string_literal: true

#
# Copyright (c) 2019-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'database_cleaner'
require 'simplecov'
require 'simplecov-console'
require 'redis'
require 'pry'

TEST_PREFIX = 'airspace_test'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner[:redis].strategy = :truncation, { only: ['airspace_test:*'] }
  end

  config.around(:each) do |example|
    DatabaseCleaner[:redis].cleaning do
      example.run
    end
  end
end

SimpleCov.formatter = SimpleCov::Formatter::Console
SimpleCov.start

require './lib/airspace'
