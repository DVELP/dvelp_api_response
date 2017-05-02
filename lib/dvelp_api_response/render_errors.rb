# frozen_string_literal: true

module DvelpApiResponse
  module RenderErrors
    def render_404_error_for(resource)
      response_data = {
        errors: [{
          body: t('render_errors.not_found', resource: resource)
        }]
      }
      build_response(response_data, :not_found)
    end

    def render_api_error(_error)
      response_data = {
        errors: [{
          body: t('render_errors.internal_server')
        }]
      }
      build_response(response_data, :internal_server_error)
    end

    def render_authorization_error
      response_data = {
        errors: [{
          body: t('render_errors.unauthorized')
        }]
      }
      build_response(response_data, :unauthorized)
    end

    def render_authy_error(error_message)
      response_data = {
        errors: [{
          body: error_message
        }]
      }
      build_response(response_data, :bad_request)
    end

    def render_destruction_error(record)
      response_data = {
        errors: [{
          body: t('render_errors.destruction'),
          meta: {
            id: record.id.to_s,
            type: record.model_name.plural.underscore
          }
        }]
      }
      build_response(response_data, :bad_request)
    end

    def render_no_content(response_data)
      build_response(response_data, :no_content)
    end

    def render_malformed_request_error(error)
      response_data = {
        errors: [{
          body: error.message
        }]
      }
      build_response(response_data, :bad_request)
    end

    def render_missing_parameter_error(param)
      response_data = {
        errors: [{
          body: t('render_errors.missing_param', param: param)
        }]
      }
      build_response(response_data, :unauthorized)
    end

    def render_routing_error(path)
      response_data = {
        errors: [{
          body: t('render_errors.routing', path: path)
        }]
      }
      build_response(response_data, :not_found)
    end

    def render_unacceptable_media_type_error
      response_data = {
        errors: [{
          body: t('render_errors.media.unacceptable')
        }]
      }
      build_response(response_data, :not_acceptable)
    end

    def render_unsupported_media_type_error
      response_data = {
        errors: [{
          body: t('render_errors.media.unsupported')
        }]
      }
      build_response(response_data, :unsupported_media_type)
    end

    def render_validation_error(record)
      response_data = {
        errors: record.errors.map do |attribute, _|
          {
            body: record.errors.full_messages_for(attribute).join(' ')
          }
        end
      }
      build_response(response_data, :bad_request)
    end

    def render_wrong_type_error
      response_data = {
        errors: [{
          body: t('render_errors.type', type: controller_name.underscore)
        }]
      }
      build_response(response_data, :bad_request)
    end
  end
end
