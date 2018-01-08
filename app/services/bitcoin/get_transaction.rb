module Services
  module Bitcoin
    module GetTransaction
      def self.perform(txid)
        client = Services::Bitcoin::GetClient.perform

        client.execute('getrawtransaction', txid, 1)
      end
    end
  end
end
