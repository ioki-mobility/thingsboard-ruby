# frozen_string_literal: true

module Thingsboard
  module Api
    class Error < StandardError; end

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
          raise Unauthorized if response.status == 401
          raise Forbidden if response.status == 403

          raise UnexpectedResponseCode, error_message_from_response(response)
        end

        return {} if response.body.blank?

        JSON.parse(response.body)
      end

      protected

      def api_endpoint
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
        process_post_request # default action
      end

      def process_post_request
        connection.post(url) do |request|
          request.headers = request_headers
          request.params = request_parameters
          request.body = request_body
        end
      end

      def process_put_request
        connection.put(url) do |request|
          request.headers = request_headers
          request.params = request_parameters
          request.body = request_body
        end
      end

      def process_get_request
        connection.get(url) do |request|
          request.headers = request_headers
          request.params = request_parameters
        end
      end

      def authorization_query
        if respond_to? :token
          "Bearer #{token}"
        else
          ''
        end
      end

      def request_headers
        {
          'Content-Type'    => 'application/json',
          'Accept'          => 'application/json',
          'X-Authorization' => authorization_query
        }
      end

      def request_parameters
        {}
      end

      def request_body
        {}.to_json
      end

      def track_request
        Thingsboard.config.request_tracker.call(api_endpoint)
      end

      def track_error(response_code)
        Thingsboard.config.error_tracker.call(api_endpoint, response_code)
      end

      def error_message_from_response(response)
        "#{response.status} >> #{response.body}"
      end
    end
  end
end
