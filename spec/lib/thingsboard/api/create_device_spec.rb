# frozen_string_literal: true

RSpec.describe Thingsboard::Api::CreateDevice do
  subject { described_class.call(operation_params) }

  let(:operation_params) do
    {
      token:               token,
      name:                name,
      type:                type,
      label:               label,
      device_access_token: device_access_token
    }
  end
  let(:response_status) { 200 }
  let(:response_body) do
    <<-JSON
      {
        "id": {
            "entityType": "DEVICE",
            "id": "85c429c0-0683-11eb-b3f7-4dbfb57ed205"
        },
        "createdTime": 1601844751964,
        "additionalInfo": null,
        "tenantId": {
            "entityType": "TENANT",
            "id": "8e71f160-db9a-11ea-95d6-fd59fd7ffce1"
        },
        "customerId": {
            "entityType": "CUSTOMER",
            "id": "13814000-1dd2-11b2-8080-808080808080"
        },
        "name": "Backend CI Traffic-Light",
        "type": "trafficlight",
        "label": "placed in ioki-prime"
      }
    JSON
  end

  let(:token) { '***TOKEN***' }

  let(:name) { 'Backend CI Traffic-Light' }
  let(:type) { 'trafficlight' }
  let(:label) { 'placed in ioki-prime' }
  let(:device_access_token) { 'HUNTER4' }

  let(:expected_endpoint) { 'api/device' }
  let(:expected_full_path) { URI.join(Thingsboard.config.base_url, expected_endpoint, "?accessToken=#{device_access_token}") }

  let(:request_body) do
    {
      name:  name,
      type:  type,
      label: label
    }.with_indifferent_access
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
          'Accept'          => 'application/json',
          'X-Authorization' => "Bearer #{token}",
          'Content-Type'    => 'application/json'
        }
      )
      .with { |request| JSON.parse(request.body) == request_body }
      .to_return(status: response_status, body: response_body)
  end

  it 'is expected to succeed' do
    expect { subject }.not_to raise_error
  end

  it 'returns the json response-body' do
    expect(subject).to eq JSON.parse(response_body)
  end

  it 'tracks the request with configured tracker' do
    expect(request_tracker).to receive(:call).with(expected_endpoint)
    subject
  end

  it 'doesn\'t track an error with configured tracker' do
    expect(error_tracker).not_to receive(:call)
    subject
  end

  context 'with a failing HTTP response' do
    let(:response_status) { 401 }
    let(:response_body) do
      '{"ok":false,"error":"Unauthorized","error_code":40101}'
    end

    it 'is expected not to succeed' do
      expect { subject }.to raise_error Thingsboard::Api::Unauthorized
    end

    it 'tracks the request and the according error with configured trackers' do
      expect(request_tracker).to receive(:call).with(expected_endpoint)
      expect(error_tracker).to receive(:call).with(expected_endpoint, response_status)
      expect { subject }.to raise_error Thingsboard::Api::Unauthorized
    end
  end
end
