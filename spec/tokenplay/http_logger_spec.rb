require 'spec_helper'

RSpec.describe TurboPlay::HTTPLogger do
  let(:logger) { StringIO.new }
  let(:http_logger) { TurboPlay::HTTPLogger.new(logger) }

  describe '#log_request' do
    it 'logs the request' do
      request = double(method: 'POST',
                       path: 'path',
                       headers: { 'Authorization' => 'test', 'Some' => 'header' },
                       body: { 'something' => 'interesting' })
      expect(logger).to receive(:info) do |log_line|
        expect(log_line).to eq(
          "[TurboPlay] Request: POST path\nAuthorization: [FILTERED]\nSome: " \
          "header\n\n{\"something\"=>\"interesting\"}\n"
        )
      end
      http_logger.log_request(request)
    end
  end

  describe '#log_response' do
    it 'logs the response' do
      response = double(status: '200',
                        path: 'path',
                        headers: { 'Content-Type' => 'application/json', 'Some' => 'header' },
                        body: { 'something' => 'interesting' })
      expect(logger).to receive(:info) do |log_line|
        expect(log_line).to eq(
          "[TurboPlay] Response: HTTP/200\nContent-Type: application/json\nSome: " \
          "header\n\n{\"something\"=>\"interesting\"}\n"
        )
      end
      http_logger.log_response(response)
    end
  end
end
