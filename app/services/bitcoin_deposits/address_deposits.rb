module Services
  module BitcoinDeposits
    module AddressDeposits
      def self.perform(address)
        BitcoinDeposit
          .association_join(:bitcoin_deposit_address)
          .where(
            Sequel.qualify(:bitcoin_deposits, :address) => address
          )
          .all
      end
    end
  end
end
