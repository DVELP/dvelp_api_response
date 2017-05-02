# frozen_string_literal: true

module DvelpApiResponse
  module HandleRequest
    require 'dvelp_api_auth/authentication'
    require 'dvelp_api_response/render_errors'
    require 'dvelp_api_response/request_validation'

    include DvelpApiAuth::Authentication
    include DvelpApiResponse::RenderErrors
    include DvelpApiResponse::RequestValidation

    def process_api_request
      authenticate_request

      yield
    rescue Unauthorized
      render_authorization_error
    rescue UnsupportedMediaType
      render_unsupported_media_type_error
    rescue UnacceptableMediaType
      render_unacceptable_media_type_error
    rescue ActiveRecord::RecordNotFound => e
      render_404_error_for e.model
    rescue ActionController::RoutingError => e
      render_routing_error e
    rescue ActiveRecord::RecordInvalid => e
      render_validation_error(e.record)
    rescue ActiveRecord::RecordNotDestroyed => e
      render_destruction_error(e.record)
    rescue ResourceTypeConflict
      render_wrong_type_error
    rescue ActionController::ParameterMissing => e
      render_missing_parameter_error(e.param)
    rescue JSON::ParserError => e
      render_malformed_request_error(e)
    rescue APIError => e
      render_api_error(e)
    end

    def raise_not_found!
      raise(
        ActionController::RoutingError,
        params[:unmatched_route]
      )
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

    private

    def multipart_request?
      request.content_type == 'multipart/form-data'
    end

    def parsed_params
      if multipart_request?
        api_params[:data][:attributes]
      else
        ActionController::Parameters.new(
          ActiveModelSerializers::Deserialization.jsonapi_parse(api_params)
        )
      end
    end
  end
end
