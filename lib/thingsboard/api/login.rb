# frozen_string_literal: true

module Thingsboard
  module Api
    class Login < Base
      receives :user
      receives :password

      protected

      def api_endpoint
        'api/auth/login'
      end

      def request_body
        {
          username: user,
          password: password
        }.to_json
      end
    end
  end
end
