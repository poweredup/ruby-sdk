require 'faraday'
require 'json'

require 'tokenplay/invalid_configuration'
require 'tokenplay/error_handler'

require 'tokenplay/http_logger'
require 'tokenplay/response'
require 'tokenplay/request'
require 'tokenplay/client'

require 'tokenplay/base'
require 'tokenplay/error'
require 'tokenplay/pagination'
require 'tokenplay/list'
require 'tokenplay/minted_token'
require 'tokenplay/setting'
require 'tokenplay/balance'
require 'tokenplay/address'
require 'tokenplay/user'
require 'tokenplay/authentication_token'
require 'tokenplay/exchange'
require 'tokenplay/transaction_source'
require 'tokenplay/transaction'

require 'tokenplay/version'
require 'tokenplay/configuration'

module TokenPlay
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
