module Workers
  module Bitcoin
    class Transaction
      include Sidekiq::Worker

      def perform(txid)
        result = Services::Bitcoin::GetTransaction.perform(txid)
        return if result['error']

        Services::BitcoinDeposits::StoreDeposit.perform(result['result'])
      end
    end
  end
end
