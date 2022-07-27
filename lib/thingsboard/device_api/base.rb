# frozen_string_literal: true

module Thingsboard
  module DeviceApi
    class Unauthorized < Error; end

    class Forbidden < Error; end

    class UnexpectedResponseCode < Error; end

    class Base
      class << self
        def call(options = {})
          raise ArgumentError, 'argument must be a Hash' unless options.is_a?(Hash)

          operation_instance = new(options)
          operation_instance.call
        end

        def receives(option_name)
          define_method option_name do
            options[option_name]
          end
        end
      end

      attr_reader :options

      def initialize(options)
        @options = options
      end

      def call
        track_request
        response = process_request

        unless [200, 201, 202].include?(response.status)
          track_error(response.status)

          error_class = if response.status == 401
                          Unauthorized
                        elsif response.status == 403
                          Forbidden
                        else
                          UnexpectedResponseCode
                        end

          raise error_class.new(
            error_message_from_response(response),
            response_status: response.status,
            response_body:   response.body
          )
        end

        return {} if response.body.blank?

        JSON.parse(response.body)
      end

      protected

      def api_endpoint
        raise NotImplementedError, 'Override in descendant classes'
      end

      def api_action
        raise NotImplementedError, 'Override in descendant classes'
      end

      private

      def connection
        Faraday.new do |faraday|
          faraday.adapter :net_http
        end
      end

      def url
        URI.join(Thingsboard.config.base_url, api_endpoint)
      end

      def process_request
        connection.post(url) do |request|
          request.headers = request_headers
          request.params = request_parameters
          request.body = request_body
        end
      end

      def request_headers
        {
          'Content-Type' => 'application/json',
          'Accept'       => 'application/json'
        }
      end

      def request_parameters
        {}
      end

      def request_body
        {}.to_json
      end

      def track_request
        Thingsboard.config.request_tracker.call(api_action)
      end

      def track_error(response_code)
        Thingsboard.config.error_tracker.call(api_action, response_code)
      end

      def error_message_from_response(response)
        "#{response.status} >> #{response.body}"
      end
    end
  end
end
