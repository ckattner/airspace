# frozen_string_literal: true

require './lib/airspace/version'

Gem::Specification.new do |s|
  s.name        = 'airspace'
  s.version     = Airspace::VERSION
  s.summary     = 'Redis Dataset Store'

  s.description = <<-DESCRIPTION
    This library provides a very simple interface for storing/fetching/paging datasets in Redis.
  DESCRIPTION

  s.authors     = ['Matthew Ruggio']
  s.email       = ['mruggio@bluemarblepayroll.com']
  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.license     = 'MIT'

  s.required_ruby_version = '>= 2.3.8'

  s.add_dependency('redis', '>=3.3.0')

  s.add_development_dependency('database_cleaner', '~>1.7')
  s.add_development_dependency('guard-rspec', '~>4.7')
  s.add_development_dependency('pry', '~>0.12')
  s.add_development_dependency('rspec', '~> 3.8')
  s.add_development_dependency('rspec_junit_formatter')
  s.add_development_dependency('rubocop', '~>0.63.1')
  s.add_development_dependency('simplecov', '~>0.16.1')
  s.add_development_dependency('simplecov-console', '~>0.4.2')
end
