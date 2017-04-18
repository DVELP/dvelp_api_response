# frozen_string_literal: true

require 'json'

module DvelpApiResponse
  module MimeTypes
    def self.install
      Mime::Type.register 'application/vnd.api+json', :jsonapi
    end
  end

  MimeTypes.install
end
