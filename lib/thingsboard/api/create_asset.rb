# frozen_string_literal: true

module Thingsboard
  module Api
    class CreateAsset < Base
      receives :token

      receives :name
      receives :type
      receives :label

      protected

      def api_endpoint
        'api/asset'
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
