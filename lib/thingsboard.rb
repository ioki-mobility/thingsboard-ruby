# frozen_string_literal: true

require_relative 'thingsboard/version'

require 'active_support/configurable'

module Thingsboard
  include ActiveSupport::Configurable
  Thingsboard.config.base_url ||= 'https://example.com/thingsboard'
  Thingsboard.config.request_tracker ||= proc { |_api_endpoint| }
  Thingsboard.config.error_tracker   ||= proc { |_api_endpoint, _response_code| }

  # require_relative 'thingsboard/api/base'
end
