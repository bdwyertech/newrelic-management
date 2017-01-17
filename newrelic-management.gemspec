# encoding: UTF-8
# rubocop: disable LineLength

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'newrelic-management/version'

Gem::Specification.new do |spec|
  spec.name          = 'newrelic-management'
  spec.version       = NewRelicManagement::VERSION
  spec.authors       = ['Brian Dwyer']
  spec.email         = ['bdwyer@IEEE.org']

  spec.summary       = %(NewRelic Management Utility)
  spec.homepage      = 'https://github.com/bdwyertech/newrelic-management'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # => Dependencies
  spec.add_runtime_dependency 'chronic_duration', '~> 0.10'
  spec.add_runtime_dependency 'faraday', '~> 0.9'
  spec.add_runtime_dependency 'faraday_middleware', '~> 0.9'
  spec.add_runtime_dependency 'net-http-persistent', '~> 2.9.4'
  spec.add_runtime_dependency 'mixlib-cli', '~> 1.7'

  # => Daemonized Background Tasks
  spec.add_runtime_dependency 'rufus-scheduler', '~> 3.3.2'

  # => Notifications
  spec.add_runtime_dependency 'os'
  spec.add_runtime_dependency 'terminal-notifier'

  # => Development Dependencies
  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
end
