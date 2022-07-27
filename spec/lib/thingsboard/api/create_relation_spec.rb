# frozen_string_literal: true



RSpec.describe Thingsboard::Api::CreateRelation do
  subject { described_class.call(operation_params) }
  let(:operation_params) do
    {
      token:            token,
      from_id:          from_id,
      from_entity_type: from_entity_type,
      to_id:            to_id,
      to_entity_type:   to_entity_type,
      relation_type:    relation_type
    }
  end

  let(:token) { '***TOKEN***' }

  let(:from_id) { '2ea8e8fd-8a3d-4788-bd7b-656edf27cf55' }
  let(:from_entity_type) { 'ASSET' }
  let(:to_id) { '8bdcb3b4-12cb-4441-9d3f-f9478d3d06f8' }
  let(:to_entity_type) { 'DEVICE' }
  let(:relation_type) { 'MANAGES' }

  let(:expected_endpoint) { 'api/relation' }
  let(:expected_full_path) { URI.join(Thingsboard.config.base_url, expected_endpoint) }

  let(:request_body) do
    {
      from: {
        'id'         => from_id,
        'entityType' => from_entity_type
      },
      to:   {
        'id'         => to_id,
        'entityType' => to_entity_type
      },
      type: relation_type
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

  let(:response_status) { 200 }
  let(:response_body) { nil }

  it 'is expected to succeed' do
    expect { subject }.not_to raise_error
  end

  it 'returns an empty hash because of missing response-body' do
    expect(subject).to eq({})
  end

  it 'tracks the request with configured tracker' do
    expect(request_tracker).to receive(:call).with(expected_endpoint)
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
      expect { subject }.to raise_error Thingsboard::Api::Unauthorized
    end

    it 'tracks the request and the according error with configured trackers' do
      expect(request_tracker).to receive(:call).with(expected_endpoint)
      expect(error_tracker).to receive(:call).with(expected_endpoint, response_status)
      expect { subject }.to raise_error Thingsboard::Api::Unauthorized
    end
  end
end
