require 'spec_helper'

RSpec.describe TokenPlay::Configuration do
  describe 'attributes' do
    describe 'pre-set ENV variables' do
      it 'uses the defined ENV variables' do
        ENV['TOKENPLAY_ACCESS_KEY'] = 'access'
        ENV['TOKENPLAY_SECRET_KEY'] = 'secret'
        ENV['TOKENPLAY_BASE_URL'] = ENV['EWALLET_URL']

        config = TokenPlay::Configuration.new
        expect(config.access_key).to eq('access')
        expect(config.secret_key).to eq('secret')
        expect(config.base_url).to eq(ENV['EWALLET_URL'])

        ENV.delete('TOKENPLAY_ACCESS_KEY')
        ENV.delete('TOKENPLAY_SECRET_KEY')
        ENV.delete('TOKENPLAY_BASE_URL')
      end
    end

    it 'can set value' do
      config = TokenPlay::Configuration.new
      config.access_key = 'access_key'
      expect(config.access_key).to eq('access_key')
    end
  end

  describe '#initialize' do
    it 'sets all the values to their defaults' do
      config = TokenPlay::Configuration.new
      expect(config.access_key).to eq(nil)
      expect(config.secret_key).to eq(nil)
      expect(config.api_version).to eq('1')
      expect(config.base_url).to eq(nil)
    end

    context 'with overriding options' do
      it 'uses the values passed as options' do
        config = TokenPlay::Configuration.new(access_key: '123')
        expect(config.access_key).to eq('123')
        expect(config.secret_key).to eq(nil)
        expect(config.api_version).to eq('1')
        expect(config.base_url).to eq(nil)
      end
    end
  end

  describe '#[]' do
    it 'returns the request value' do
      expect(TokenPlay::Configuration.new[:base_url]).to eq(nil)
    end
  end

  describe '#to_hash' do
    it 'returns the configuration as a hash' do
      expect(TokenPlay::Configuration.new.to_hash).to eq(
        access_key: nil,
        secret_key: nil,
        base_url: nil,
        logger: nil
      )
    end
  end

  describe '#merge' do
    it 'merges the given options' do
      config = TokenPlay::Configuration.new
      config.merge(access_key: 'access_key')
      expect(config.access_key).to eq('access_key')
    end
  end
end
