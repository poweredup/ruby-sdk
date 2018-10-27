require 'spec_helper'

module TurboPlay
  RSpec.describe Response do
    let(:config) { TurboPlay::Configuration.new }
    let(:client) { TurboPlay::Client.new(config) }

    describe '#success?' do
      context 'when success is true' do
        it 'retuns true' do
          response = TurboPlay::Response.new({ 'success' => true }, client)
          expect(response.success?).to eq true
        end
      end

      context 'when success is false' do
        it 'retuns false' do
          response = TurboPlay::Response.new({ 'success' => false }, client)
          expect(response.success?).to eq false
        end
      end
    end

    describe '#version' do
      it 'returns the version' do
        response = TurboPlay::Response.new({ 'version' => '1' }, client)
        expect(response.version).to eq '1'
      end
    end

    describe '#data' do
      context 'when the object is unknown' do
        it 'raises an Unknown Object error' do
          response = TurboPlay::Response.new({
                                             'data' => {
                                               'object' => 'foo'
                                             }
                                           },
                                           client)

          expect { response.data }.to raise_error("Unknown Object 'foo'")
        end
      end

      context 'when the object is known' do
        it 'instantiates the appropriate model' do
          response = TurboPlay::Response.new({
                                             'data' => {
                                               'object' => 'user',
                                               'id' => '123'
                                             }
                                           },
                                           client)

          expect(response.data).to be_kind_of TurboPlay::User
        end
      end
    end
  end
end
