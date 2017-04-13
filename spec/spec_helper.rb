# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'dvelp_api_response'

require 'combustion'
Combustion.initialize! :all

require 'byebug'
require 'database_cleaner'
require 'rspec/rails'

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.use_transactional_fixtures = true

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.order = :random
end
