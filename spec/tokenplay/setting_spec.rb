require 'spec_helper'

module TokenPlay
  RSpec.describe Setting do
    let(:config) do
      TokenPlay::Configuration.new(
        access_key: ENV['ACCESS_KEY'],
        secret_key: ENV['SECRET_KEY'],
        base_url: ENV['EWALLET_URL']
      )
    end
    let(:client) { TokenPlay::Client.new(config) }

    describe '.all' do
      it 'retrieves all the settings' do
        VCR.use_cassette('setting/all') do
          settings = TokenPlay::Setting.all(client: client)

          expect(settings).to be_kind_of TokenPlay::Setting
          expect(settings.minted_tokens.first).to be_kind_of TokenPlay::MintedToken
          expect(settings.minted_tokens.last).to be_kind_of TokenPlay::MintedToken
        end
      end
    end
  end
end
