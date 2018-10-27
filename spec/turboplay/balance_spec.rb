require 'spec_helper'
require 'securerandom'

module TurboPlay
  RSpec.describe Balance do
    let(:config) do
      TurboPlay::Configuration.new(
        access_key: ENV['ACCESS_KEY'],
        secret_key: ENV['SECRET_KEY'],
        base_url: ENV['EWALLET_URL']
      )
    end
    let(:client) { TurboPlay::Client.new(config) }
    let(:attributes) { { id: '123' } }

    describe '.all' do
      it 'retrieves the list of balances' do
        VCR.use_cassette('balance/all') do
          expect(ENV['PROVIDER_USER_ID']).not_to eq nil
          list = TurboPlay::Balance.all(
            provider_user_id: ENV['PROVIDER_USER_ID'],
            client: client
          )
          expect(list).to be_kind_of TurboPlay::List
          expect(list.first).to be_kind_of TurboPlay::Address
          expect(list.first.balances.first).to be_kind_of TurboPlay::Balance
          expect(list.first.balances.first.minted_token).to be_kind_of TurboPlay::MintedToken
        end
      end
    end

    describe '.credit' do
      context 'with valid params' do
        it "credits the user's balance" do
          VCR.use_cassette('balance/credit/valid') do
            expect(ENV['PROVIDER_USER_ID']).not_to eq nil
            balances = TurboPlay::Balance.credit(
              provider_user_id: ENV['PROVIDER_USER_ID'],
              token_id: ENV['TOKEN_ID'],
              amount: 10_000,
              client: client,
              idempotency_token: SecureRandom.uuid
            )

            expect(balances).to be_kind_of TurboPlay::List
            address = balances.first
            expect(address).to be_kind_of TurboPlay::Address
          end
        end
      end

      context 'with optional params account_id and burn_balance_identifier' do
        it "credits the user's balance" do
          VCR.use_cassette('balance/credit/valid_optional') do
            expect(ENV['PROVIDER_USER_ID']).not_to eq nil
            balances = TurboPlay::Balance.credit(
              account_id: ENV['ACCOUNT_ID'],
              burn_balance_identifier: 'burn',
              provider_user_id: ENV['PROVIDER_USER_ID'],
              token_id: ENV['TOKEN_ID'],
              amount: 10_000,
              client: client,
              idempotency_token: SecureRandom.uuid
            )

            expect(balances).to be_kind_of TurboPlay::List
          end
        end
      end
    end

    describe '.debit' do
      context 'with valid params' do
        it "debits the user's balance" do
          VCR.use_cassette('balance/debit/valid') do
            expect(ENV['PROVIDER_USER_ID']).not_to eq nil
            balances = TurboPlay::Balance.debit(
              provider_user_id: ENV['PROVIDER_USER_ID'],
              token_id: ENV['TOKEN_ID'],
              amount: 1000,
              client: client,
              idempotency_token: SecureRandom.uuid
            )

            expect(balances).to be_kind_of TurboPlay::List
          end
        end
      end

      context 'with optional params account_id and burn_balance_identifier' do
        it "debit/s the user's balance" do
          VCR.use_cassette('balance/debit/valid_optional') do
            expect(ENV['PROVIDER_USER_ID']).not_to eq nil
            balances = TurboPlay::Balance.debit(
              account_id: ENV['ACCOUNT_ID'],
              burn_balance_identifier: 'burn',
              provider_user_id: ENV['PROVIDER_USER_ID'],
              token_id: ENV['TOKEN_ID'],
              amount: 10_000,
              client: client,
              idempotency_token: SecureRandom.uuid
            )

            expect(balances).to be_kind_of TurboPlay::List
          end
        end
      end
    end
  end
end
