module TurboPlay
  class Client
    attr_accessor :config

    def initialize(options = nil)
      @config = load_config(options)
    end

    def call(path, params)
      request.call(path: path, body: params)
    end

    def request
      @request ||= Request.new(self)
    end

    private

    def load_config(options)
      return TurboPlay.configuration unless options
      Configuration.new(options.to_hash)
    end
  end
end
