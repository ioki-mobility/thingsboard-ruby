# frozen_string_literal: true

require 'bundler/setup'
require 'thingsboard'
require 'faraday'
require 'active_support/core_ext/string'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/securerandom'
require 'active_support/core_ext/time/zones'
require 'webmock/rspec'

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }
Time.zone = 'UTC'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
