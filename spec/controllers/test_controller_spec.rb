# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TestController, type: :controller do
  describe 'API infrastructure' do
    controller(TestController) do
      def create
        build_response(parsed_params.slice('email'), :ok)
      end

      def index
        build_response({}, :ok)
      end

      def update
        build_response({}, :ok)
      end

      def destroy
        build_response({}, :ok)
      end

      def error_not_found
        raise ActiveRecord::RecordNotFound.new(nil, 'TestRecord')
      end

      def error_validation
        test_record = TestRecord.new
        test_record.validate

        raise ActiveRecord::RecordInvalid, test_record
      end

      def error_destruction
        test_record = TestRecord.new id: 1

        raise ActiveRecord::RecordNotDestroyed.new(nil, test_record)
      end

      def error_routing
        raise_not_found!
      end

      def error_type_conflict
        raise RequestTypeConflict
      end

      def error_missing_parameters
        params.require(:missing)
      end

      def error_json
        JSON.parse('{this is not a JSON')
      end
    end

    before do
      routes.draw do
        resources :test do
          collection do
            get :error_destruction
            get :error_json
            get :error_missing_parameters
            get :error_not_found
            get :error_routing
            get :error_validation
            post :error_type_conflict
          end
        end
      end
    end

    describe 'authentication' do
      it 'renders an error when token is missing' do
        api_request :get, :index

        expect(response).to have_http_status :unauthorized

        expect(parsed_response)
          .to eq(response_error('Unauthorized'))
      end

      it 'renders an error when token is incorrect' do
        fill_auth_headers(fullpath: '/wrong_path.jsonapi')

        api_request :get, :index

        expect(response).to have_http_status :unauthorized

        expect(parsed_response)
          .to eq(response_error('Unauthorized'))
      end

      it 'renders the action when token is OK' do
        fill_auth_headers(fullpath: '/test.jsonapi')

        api_request :get, :index

        expect(response).to have_http_status :ok
      end
    end

    describe 'payload type check' do
      it 'renders the action when the type is OK' do
        payload = { data: { type: 'test' } }

        fill_auth_headers(fullpath: '/test/1', raw_post: payload.to_json)

        api_request :patch, :update, payload: payload

        expect(response).to have_http_status :ok
      end

      it 'renders an error on type mismatch' do
        payload = { data: { type: 'wrong_type' } }

        fill_auth_headers(fullpath: '/test/1', raw_post: payload.to_json)

        api_request :patch, :update, payload: payload

        expect(response).to have_http_status :bad_request

        expect(parsed_response)
          .to eq(response_error('Incorrect type, expected type is test'))
      end

      it "doesn't check type for get requests" do
        payload = { data: { type: 'wrong_type' } }

        fill_auth_headers(fullpath: '/test/1', raw_post: payload.to_json)

        api_request :get, :index, payload: payload

        expect(response).to have_http_status :ok
      end
    end

    describe 'not found error handling' do
      it 'renders error' do
        fill_auth_headers(fullpath: '/test/error_not_found.jsonapi')

        api_request :get, :error_not_found

        expect(response).to have_http_status :not_found

        expect(parsed_response)
          .to eq(response_error('TestRecord not found'))
      end
    end

    describe 'validation error handling' do
      it 'renders error' do
        fill_auth_headers(fullpath: '/test/error_validation.jsonapi')

        api_request :get, :error_validation

        expect(response).to have_http_status :bad_request

        expect(parsed_response)
          .to eq(response_error("Name can't be blank"))
      end
    end

    describe 'destruction error handling' do
      it 'renders error' do
        fill_auth_headers(fullpath: '/test/error_destruction.jsonapi')

        api_request :get, :error_destruction

        expect(response).to have_http_status :bad_request

        expect(parsed_response)
          .to eq(response_error(
            'Failed to delete the resource',
            'id' => '1',
            'type' => 'test_records'
          ))
      end
    end

    describe 'type conflict error handling' do
      it 'renders error' do
        payload = { data: { type: 'something_completely_different' } }

        fill_auth_headers(fullpath: '/test/error_type_conflict.jsonapi',
                          raw_post: payload.to_json)

        api_request :post, :error_type_conflict, payload: payload

        expect(response).to have_http_status :bad_request

        expect(parsed_response)
          .to eq(response_error('Incorrect type, expected type is test'))
      end
    end

    describe 'missing params error handling' do
      it 'renders error' do
        fill_auth_headers(
          fullpath: '/test/error_missing_parameters.jsonapi'
        )

        api_request :get, :error_missing_parameters

        expect(response).to have_http_status :unauthorized

        expect(parsed_response).to eq(
          response_error('Missing parameter: missing')
        )
      end
    end

    describe 'JSON parsing error handling' do
      it 'renders error' do
        fill_auth_headers(fullpath: '/test/error_json.jsonapi')

        api_request :get, :error_json

        expect(response).to have_http_status :bad_request

        expect(parsed_response['errors'][0]['body'])
          .to include('unexpected token at')
      end
    end

    describe 'routing error handling' do
      it 'renders error' do
        fill_auth_headers(fullpath: '/test/error_routing.jsonapi')

        api_request(
          :get,
          :error_routing,
          params: { unmatched_route: '/test/error_routing' }
        )

        expect(response).to have_http_status :not_found

        expect(parsed_response)
          .to eq(response_error('No route matches /test/error_routing'))
      end
    end

    describe 'unsupported media type error handling' do
      it 'renders error' do
        fill_auth_headers(fullpath: '/test/1.html')

        api_request :patch, :update, media_type: :html

        expect(response).to have_http_status :unsupported_media_type

        expect(parsed_response)
          .to eq(response_error('Unsupported media type'))
      end
    end

    describe 'unacceptable media type error handling' do
      it 'renders error' do
        fill_auth_headers(fullpath: '/test.html')

        api_request :get, :index, media_type: :html

        expect(response).to have_http_status :not_acceptable

        expect(parsed_response)
          .to eq(response_error('Unacceptable media type'))
      end
    end

    describe 'params' do
      context 'when multipart' do
        it 'returns parsed params' do
          attributes = {
            avatar: Rack::Test::UploadedFile.new(
              File.open(
                Rails.root.join('fixtures', 'images', 'test.jpg')
              )
            ),
            email: 'richard@dvelp.co.uk'
          }

          payload = {
            data: {
              type: 'test',
              attributes: attributes
            }
          }

          fill_auth_headers(
            fullpath: '/test.jsonapi',
            multipart: true,
            body: build_multipart(payload)
          )

          api_request :post, :create, params: payload

          expected_response = {
            'email' => 'richard@dvelp.co.uk'
          }

          expect(response).to have_http_status :ok

          expect(parsed_response).to eq expected_response
        end
      end

      context 'when json' do
        it 'returns parsed params' do
          customer_attributes = {
            email: 'richard@dvelp.co.uk'
          }

          payload = {
            data: {
              type: 'test',
              attributes: customer_attributes
            }
          }

          fill_auth_headers(
            fullpath: '/test.jsonapi',
            raw_post: payload.to_json
          )

          api_request :post, :create, payload: payload

          expected_response = {
            'email' => 'richard@dvelp.co.uk'
          }

          expect(response).to have_http_status :ok

          expect(parsed_response).to eq expected_response
        end
      end
    end
  end
end
