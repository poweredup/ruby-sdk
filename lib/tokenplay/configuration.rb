module TurboPlay
  class Configuration
    OPTIONS = {
      access_key: -> { ENV['TURBOPLAY_ACCESS_KEY'] },
      secret_key: -> { ENV['TURBOPLAY_SECRET_KEY'] },
      base_url: -> { ENV['TURBOPLAY_BASE_URL'] },
      logger: nil
    }.freeze

    TURBOPLAY_OPTIONS = {
      api_version: '1',
      auth_scheme: 'PLAYServer',
      models: {
        user: TurboPlay::User,
        error: TurboPlay::Error,
        authentication_token: TurboPlay::AuthenticationToken,
        address: TurboPlay::Address,
        balance: TurboPlay::Balance,
        minted_token: TurboPlay::MintedToken,
        list: TurboPlay::List,
        setting: TurboPlay::Setting,
        transaction: TurboPlay::Transaction,
        exchange: TurboPlay::Exchange,
        transaction_source: TurboPlay::TransactionSource
      }
    }.freeze

    attr_accessor(*OPTIONS.keys)
    attr_reader(*TURBOPLAY_OPTIONS.keys)

    def initialize(options = {})
      OPTIONS.each do |name, val|
        value = options ? options[name] || options[name.to_sym] : nil
        value ||= val.call if val.respond_to?(:call)
        instance_variable_set("@#{name}", value)
      end

      TURBOPLAY_OPTIONS.each do |name, value|
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
