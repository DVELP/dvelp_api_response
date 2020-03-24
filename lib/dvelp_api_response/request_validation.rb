# frozen_string_literal: true

module DvelpApiResponse
  module RequestValidation
    def valid_resource_type?
      return true if action_name == 'raise_not_found!'
      return true if request.delete? || request.get?

      type = api_params.require(:data).require(:type)
      type == controller_name.underscore
    end

    def valid_request_media_type?
      return true if request.delete? || request.get?

      valid_content_types.include? request.content_type
    end

    def valid_response_media_type?
      request.accepts.any? do |media_type|
        valid_content_types.include? media_type
      end
    end

    def api_params
      @api_params ||=
        if multipart_request?
          params
        else
          ActionController::Parameters.new(
            Oj.load(request.raw_post)
          )
        end
    end

    private

    def valid_content_types
      [Mime[:jsonapi], 'multipart/form-data']
    end
  end
end
