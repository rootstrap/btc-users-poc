require './lib/bitcoin/client'

module Services
  module Bitcoin
    module GetClient
      RPC_USER = ENV.fetch('BTC_RPC_USER')
      RPC_PASSWORD = ENV.fetch('BTC_RPC_PASSWORD')
      RPC_HOST = ENV.fetch('BTC_RPC_HOST')
      RPC_PORT = ENV.fetch('BTC_RPC_PORT')

      def self.perform
        ::Bitcoin::Client.new(
          user: RPC_USER,
          password: RPC_PASSWORD,
          host: RPC_HOST,
          port: RPC_PORT
        )
      end
    end
  end
end
