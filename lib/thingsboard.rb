# frozen_string_literal: true

require_relative 'thingsboard/version'
require 'active_support'
require 'active_support/configurable'

module Thingsboard
  include ActiveSupport::Configurable
  Thingsboard.config.base_url ||= 'https://example.com/thingsboard'
  Thingsboard.config.request_tracker ||= proc { |_api_endpoint| }
  Thingsboard.config.error_tracker   ||= proc { |_api_endpoint, _response_code| }

  require_relative 'thingsboard/api/base'
  require_relative 'thingsboard/api/create_asset'
  require_relative 'thingsboard/api/create_device'
  require_relative 'thingsboard/api/create_relation'
  require_relative 'thingsboard/api/login'
  require_relative 'thingsboard/device_api/error'
  require_relative 'thingsboard/device_api/base'
  require_relative 'thingsboard/device_api/create_telemetries'
end
