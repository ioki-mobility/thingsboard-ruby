# frozen_string_literal: true

module Thingsboard
  module Api
    class CreateDevice < Base
      receives :token

      receives :name
      receives :type
      receives :label
      receives :device_access_token

      protected

      def api_endpoint
        'api/device'
      end

      def request_parameters
        {
          'accessToken' => device_access_token
        }
      end

      def request_body
        {
          name:  name,
          type:  type,
          label: label
        }.to_json
      end
    end
  end
end
