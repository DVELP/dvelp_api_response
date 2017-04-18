# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
ENV['DVELP_API_AUTH_SECRET_KEY'] = ''

require 'kaminari'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'dvelp_api_response'

require 'combustion'
Combustion.initialize! :all

require 'byebug'
require 'database_cleaner'
require 'dvelp_api_auth'
require 'faker'
require 'factory_girl_rails'
require 'rspec/rails'

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load translations to use in specs
I18n.backend.store_translations(
  :en,
  YAML.load_file(File.open('./config/locales/en.yml'))['en']
)

RSpec.configure do |config|
  config.include ApiRequestHelper, type: :controller
  config.use_transactional_fixtures = true
  config.include FactoryGirl::Syntax::Methods

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.order = :random
end
