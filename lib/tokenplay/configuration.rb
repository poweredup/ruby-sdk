module TokenPlay
  class Configuration
    OPTIONS = {
      access_key: -> { ENV['TOKENPLAY_ACCESS_KEY'] },
      secret_key: -> { ENV['TOKENPLAY_SECRET_KEY'] },
      base_url: -> { ENV['TOKENPLAY_BASE_URL'] },
      logger: nil
    }.freeze

    TOKENPLAY_OPTIONS = {
      api_version: '1',
      auth_scheme: 'PLAYServer',
      models: {
        user: TokenPlay::User,
        error: TokenPlay::Error,
        authentication_token: TokenPlay::AuthenticationToken,
        address: TokenPlay::Address,
        balance: TokenPlay::Balance,
        minted_token: TokenPlay::MintedToken,
        list: TokenPlay::List,
        setting: TokenPlay::Setting,
        transaction: TokenPlay::Transaction,
        exchange: TokenPlay::Exchange,
        transaction_source: TokenPlay::TransactionSource
      }
    }.freeze

    attr_accessor(*OPTIONS.keys)
    attr_reader(*TOKENPLAY_OPTIONS.keys)

    def initialize(options = {})
      OPTIONS.each do |name, val|
        value = options ? options[name] || options[name.to_sym] : nil
        value ||= val.call if val.respond_to?(:call)
        instance_variable_set("@#{name}", value)
      end

      TOKENPLAY_OPTIONS.each do |name, value|
        instance_variable_set("@#{name}", value)
      end
    end

    def [](option)
      instance_variable_get("@#{option}")
    end

    def to_hash
      OPTIONS.keys.each_with_object({}) do |option, hash|
        hash[option.to_sym] = self[option]
      end
    end

    def merge(options)
      OPTIONS.each_key do |name|
        instance_variable_set("@#{name}", options[name]) if options[name]
      end
    end
  end
end
