# frozen_string_literal: true

require 'active_model_serializers'
require 'dvelp_api_response/version'
Gem.find_files('dvelp_api_response/**/*.rb').each { |f| require f }

module DvelpApiResponse
end
