# frozen_string_literal: true

RSpec.describe Thingsboard::Api::Base do
  subject { described_class.call(operation_params) }

  let(:operation_params) do
    {
      foo: foo
    }
  end
  let(:foo) { 'foo' }

  let(:request_body) { { dummy_request: 'DUMMY REQUEST' }.to_json }
  let(:response_body) { { dummy_response: 'DUMMY RESPONSE' }.to_json }
  let(:response_status) { 200 }

  let(:expected_endpoint) { 'dummy' }
  let(:expected_full_path) { URI.join(Thingsboard.config.base_url, expected_endpoint) }

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
        body:    request_body,
        headers: {
          'Accept'          => 'application/json',
          'X-Authorization' => '',
          'Content-Type'    => 'application/json'
        }
      )
      .to_return(status: response_status, body: response_body)
  end

  context 'as instantiated class with implementation' do
    dummy_class(:thingsboard_api_class, described_class) do
      def api_endpoint
        'dummy'
      end

      def request_body
        { dummy_request: 'DUMMY REQUEST' }.to_json
      end
    end

    subject { thingsboard_api_class.call(operation_params) }

    context 'with a successful HTTP response' do
      let(:response_status) { 200 }

      it 'is expected to succeed' do
        expect { subject }.not_to raise_error
      end

      it 'returns the parsed json of the response-body' do
        expect(subject).to eq JSON.parse(response_body)
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
    end

    context 'with a failing HTTP response' do
      let(:response_status) { 999 }

      it 'is expected not to succeed' do
        expect { subject }.to raise_error Thingsboard::Api::UnexpectedResponseCode
      end

      it 'tracks the request and the according error with configured trackers' do
        expect(request_tracker).to receive(:call).with(expected_endpoint)
        expect(error_tracker).to receive(:call).with(expected_endpoint, response_status)
        expect { subject }.to raise_error Thingsboard::Api::UnexpectedResponseCode
      end

      context 'when request failed with http-status 401' do
        let(:response_status) { 401 }
        let(:response_body) do
          '{"ok":false,"error":"Unauthorized","error_code":40101}'
        end

        it 'is expected to raise Thingsboard::Api::Unauthorized' do
          expect { subject }.to raise_error Thingsboard::Api::Unauthorized
        end
      end

      context 'when request failed with http-status 403' do
        let(:response_status) { 403 }

        it 'is expected to raise Thingsboard::Api::Forbidden' do
          expect { subject }.to raise_error Thingsboard::Api::Forbidden
        end
      end

      context 'when request failed with http-status 400' do
        let(:response_status) { 400 }
        let(:response_body) do
          '{"ok":false,"error":"SomeRandomError","error_code":40001}'
        end

        it 'is expected to raise Thingsboard::Api::Unauthorized' do
          expect { subject }.to raise_error Thingsboard::Api::UnexpectedResponseCode
        end

        context 'when response-body contains invalid json' do
          let(:response_body) do
            'false}'
          end

          it 'won\'t change the according error-type' do
            expect { subject }.to raise_error Thingsboard::Api::UnexpectedResponseCode
          end
        end
      end
    end
  end
end
