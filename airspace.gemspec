# frozen_string_literal: true

require './lib/airspace/version'

Gem::Specification.new do |s|
  s.name        = 'airspace'
  s.version     = Airspace::VERSION
  s.summary     = 'This library is currently under construction.'

  s.description = <<-DESCRIPTION
    This library is currently under construction.
  DESCRIPTION

  s.authors     = ['Matthew Ruggio']
  s.email       = ['mruggio@bluemarblepayroll.com']
  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.homepage    = 'https://github.com/bluemarblepayroll/airspace'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 2.3.8'

  s.add_development_dependency('guard-rspec', '~>4.7')
  s.add_development_dependency('rspec', '~> 3.8')
  s.add_development_dependency('rubocop', '~>0.63.1')
  s.add_development_dependency('simplecov', '~>0.16.1')
  s.add_development_dependency('simplecov-console', '~>0.4.2')
end