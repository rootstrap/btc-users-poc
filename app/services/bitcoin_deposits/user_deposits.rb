module Services
  module BitcoinDeposits
    module UserDeposits
      def self.perform(user)
        BitcoinDeposit
          .association_join(:bitcoin_deposit_address)
          .where(user_id: user.id)
          .all
      end
    end
  end
end
