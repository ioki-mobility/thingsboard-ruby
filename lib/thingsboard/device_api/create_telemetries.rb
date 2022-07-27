# frozen_string_literal: true

module Thingsboard
  module DeviceApi
    class CreateTelemetries < Base
      receives :device_access_token
      receives :telemetry_data

      protected

      def api_endpoint
        "api/v1/#{device_access_token}/telemetry"
      end

      def api_action
        'api/v1/:device_access_token/telemetry'
      end

      def request_body
        telemetry_data.to_json
      end
    end
  end
end
