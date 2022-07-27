# frozen_string_literal: true

RSpec.describe Thingsboard::DeviceApi::CreateTelemetries do
  subject { described_class.call(operation_params) }

  let(:operation_params) do
    {
      device_access_token: device_access_token,
      telemetry_data:      telemetry_data
    }
  end
  let(:response_status) { 201 }
  let(:response_body) { {}.to_json }

  let(:recorded_at) { '2020-01-01 12:00:00 +0000'.to_datetime }
  let(:recorded_at_ts) { (recorded_at.to_f * 1000).to_i }

  let(:telemetry_data) do
    [
      {
        ts:     recorded_at_ts,
        values: {
          'location.latitude':  49.0,
          'location.longitude': 9.0,
          'location.altitude':  nil,
          'location.heading':   122.0,
          'location.speed':     15.0,
          'location.accuracy':  18.0
        }
      }
    ]
  end

  let(:device_access_token) { 'SECRET_DEVICE_ACCESS_TOKEN' }
  let(:expected_full_path) { URI.join(Thingsboard.config.base_url, "api/v1/#{device_access_token}/telemetry") }
  let(:expected_api_action) { 'api/v1/:device_access_token/telemetry' }

  let(:request_body) do
    telemetry_data.to_json
  end

  let(:request_tracker) do
    proc do |api_endpoint|
      api_endpoint
    end
  end

  let(:error_tracker) do
    proc do |api_endpoint, response_code|
      [api_endpoint, response_code]
    end
  end

  before do
    allow(Thingsboard.config).to receive(:request_tracker).and_return(request_tracker)
    allow(Thingsboard.config).to receive(:error_tracker).and_return(error_tracker)

    stub_request(:post, expected_full_path)
      .with(
        headers: {
          'Accept'       => 'application/json',
          'Content-Type' => 'application/json'
        }
      )
      .with { |request| JSON.parse(request.body) == JSON.parse(request_body) }
      .to_return(status: response_status, body: response_body)
  end

  it 'is expected to succeed' do
    expect { subject }.not_to raise_error
  end

  it 'returns the json response-body' do
    expect(subject).to eq JSON.parse(response_body)
  end

  it 'tracks the request with configured tracker' do
    expect(request_tracker).to receive(:call).with(expected_api_action)
    subject
  end

  it 'doesn\'t track an error with Prometheus' do
    expect(PrometheusMetrics).not_to receive(:observe).with(
      :third_party_errors_total,
      1,
      hash_including(provider: 'thingsboard')
    )

    subject
  end

  context 'with a failing HTTP response' do
    let(:response_status) { 401 }
    let(:response_body) do
      '{"ok":false,"error":"Unauthorized","error_code":40101}'
    end

    it 'is expected not to succeed' do
      expect { subject }.to raise_error Thingsboard::DeviceApi::Unauthorized
    end

    it 'tracks the request and the according error with configured trackers' do
      expect(request_tracker).to receive(:call).with(expected_api_action)
      expect(error_tracker).to receive(:call).with(expected_api_action, response_status)
      expect { subject }.to raise_error Thingsboard::DeviceApi::Unauthorized
    end
  end
end
