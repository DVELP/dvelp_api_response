# frozen_string_literal: true

module DvelpApiResponse
  module ApiRequestHelper
    include Rack::Test::Utils

    public :build_multipart

    def fill_auth_headers(fullpath:, raw_post: '',
      timestamp: Time.current, multipart: false, body: nil)

      fill_authorisation_header(fullpath, raw_post, timestamp, multipart, body)
      fill_timestamp(timestamp)
    end

    def parsed_response
      @parsed_response ||= parse_body(response.body)
    end

    def response_error(body, meta = nil)
      error_message = { 'body' => body }
      error_message['meta'] = meta if meta
      { 'errors' => [error_message] }
    end

    def api_request(method, action, params: {}, payload: {}, media_type: :jsonapi)

      url_params =
        if %i[update show destroy].include? action
          { id: 1 }
        else
          {}
        end.merge(params)

      fill_accept(media_type)

      process_params = { method: method, params: url_params, as: media_type }

      process_params[:body] = jsonify_payload(payload) if payload.present?

      process(
        action,
        **process_params
      )
    end

    private

    def fill_authorisation_header(
      fullpath, raw_post, timestamp, multipart, body
    )
      request.env['HTTP_AUTHORISATION'] =
        DvelpApiAuth::Authentication::Signature.new(
          fullpath, raw_post, timestamp, multipart, body
        ).generate
    end

    def fill_timestamp(timestamp)
      request.env['HTTP_TIMESTAMP'] = timestamp
    end

    def fill_accept(media_type)
      request.set_header 'HTTP_ACCEPT', Mime[media_type].to_s
    end

    def jsonify_payload(hash)
      Oj.dump(hash, mode: :rails, time_format: :ruby)
    end

    def parse_body(json)
      Oj.load(json)
    end
  end
end
