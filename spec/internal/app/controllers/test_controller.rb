# frozen_string_literal: true

class TestController < ActionController::Base
  require_dependency 'dvelp_api_response/handle_request'

  include DvelpApiResponse::HandleRequest

  around_action :process_api_request

  def build_response(response, status)
    render(json: response, status: status) && return
  end
end
