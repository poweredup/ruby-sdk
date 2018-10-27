require 'spec_helper'

module TurboPlay
  RSpec.describe Setting do
    let(:config) do
      TurboPlay::Configuration.new(
        access_key: ENV['ACCESS_KEY'],
        secret_key: ENV['SECRET_KEY'],
        base_url: ENV['EWALLET_URL']
      )
    end
    let(:client) { TurboPlay::Client.new(config) }

    describe '.all' do
      it 'retrieves all the settings' do
        VCR.use_cassette('setting/all') do
          settings = TurboPlay::Setting.all(client: client)

          expect(settings).to be_kind_of TurboPlay::Setting
          expect(settings.minted_tokens.first).to be_kind_of TurboPlay::MintedToken
          expect(settings.minted_tokens.last).to be_kind_of TurboPlay::MintedToken
        end
      end
    end
  end
end
