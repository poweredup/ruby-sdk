require 'faraday'
require 'json'

require 'turboplay/invalid_configuration'
require 'turboplay/error_handler'

require 'turboplay/http_logger'
require 'turboplay/response'
require 'turboplay/request'
require 'turboplay/client'

require 'turboplay/base'
require 'turboplay/error'
require 'turboplay/pagination'
require 'turboplay/list'
require 'turboplay/minted_token'
require 'turboplay/setting'
require 'turboplay/balance'
require 'turboplay/address'
require 'turboplay/user'
require 'turboplay/authentication_token'
require 'turboplay/exchange'
require 'turboplay/transaction_source'
require 'turboplay/transaction'

require 'turboplay/version'
require 'turboplay/configuration'

module TurboPlay
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
