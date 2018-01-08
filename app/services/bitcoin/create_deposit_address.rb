module Services
  module Bitcoin
    module CreateDepositAddress
      def self.perform(user)
        client = Services::Bitcoin::GetClient.perform

        result = client.execute('getnewaddress')

        BitcoinDepositAddress.create(
          address: result['result'],
          total: 0,
          user_id: user.id,
          created_at: Time.now.utc
        )
      end
    end
  end
end
