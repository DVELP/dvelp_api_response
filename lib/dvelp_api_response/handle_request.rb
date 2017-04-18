# frozen_string_literal: true

module DvelpApiResponse
  module HandleRequest
    require 'dvelp_api_auth/authentication'
    require 'dvelp_api_response/request_validation'

    include DvelpApiAuth::Authentication
    include DvelpApiResponse::RequestValidation

    def process_api_request
      authenticate_request

      yield
    end

    def authenticate_request
      begin
        raise Unauthorized unless valid_request?
      rescue
        raise Unauthorized
      end
      raise UnsupportedMediaType unless valid_request_media_type?
      raise UnacceptableMediaType unless valid_response_media_type?
      raise ResourceTypeConflict unless valid_resource_type?
    end
  end
end
