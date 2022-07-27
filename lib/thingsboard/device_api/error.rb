# frozen_string_literal: true

module Thingsboard
  module DeviceApi
    class Error < ::StandardError
      attr_reader :meta_data

      def initialize(message, meta_data = {})
        @meta_data = meta_data
        super(message)
      end

      def response_status
        meta_data.try :[], :response_status
      end

      def response_body
        meta_data.try :[], :response_body
      end
    end
  end
end
