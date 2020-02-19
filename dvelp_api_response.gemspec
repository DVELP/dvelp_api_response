# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dvelp_api_response/version'

Gem::Specification.new do |spec|
  spec.name          = 'dvelp_api_response'
  spec.version       = DvelpApiResponse::VERSION
  spec.authors       = ['Richard Brown']
  spec.email         = ['richard@dvelp.co.uk']

  spec.summary       = 'Provides standardised response to api requests.'
  spec.homepage      = 'http://dvelp.co.uk'
  spec.license       = 'MIT'

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'active_model_serializers'
  spec.add_dependency 'dvelp_api_auth', '0.5.0'
  spec.add_dependency 'kaminari'
  spec.add_dependency 'rails'

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'combustion'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'factory_bot_rails'
  spec.add_development_dependency 'faker'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rack-test', '0.7.0'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'rubocop', '0.80.0'
  spec.add_development_dependency 'sqlite3'
end
