# frozen_string_literal: true

module DvelpApiResponse
  module RequestValidation
    def valid_resource_type?
      return true if request.delete? || request.get?

      type = api_params.require(:data).require(:type)
      type == controller_name.underscore
    end

    def valid_request_media_type?
      return true if request.delete? || request.get?

      request.content_type == Mime[:jsonapi]
    end

    def valid_response_media_type?
      request.accepts.any? do |media_type|
        media_type == Mime[:jsonapi]
      end
    end

    def api_params
      @api_params ||=
        ActionController::Parameters.new(
          JSON.parse(request.body.read)
        )
    end
  end
end
