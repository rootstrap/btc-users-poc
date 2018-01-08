module Services
  module BitcoinDeposits
    module StoreDeposit
      SATOSHI_BTC = 100_000_000

      # Store deposits from a transaction
      #
      # To take into account:
      #   Confirmations:
      #   - Transactions with no confirmations can't
      #     be trusted.
      #   - Transactions with one confirmation could
      #     be considered safe enough (for small amounts).
      #   - Transactions with more than three
      #     confirmations are safe.
      #
      #   Outputs:
      #   - Transactions can contain multiple outputs.
      #   - Each output will be handled as a single deposit.
      #     This could hopefully help track them more precisely.
      #   - Multiple outputs could be for the same address.
      #
      #  Balance:
      #   - Balance to the user is added when transaction
      #     is received (no confirmations required).
      #   - Unconfirmed transactions add up to unconfirmed_balance
      #     Real balance = balance - unconfirmed_balance
      #
      #  TODO:
      #   - We are assuming the user balance is 1 = 1 with BTC.
      #     Exchange rate must be handled here.
      def self.perform(transaction)
        txid = transaction['txid']

        confirmations = transaction['confirmations'] || 0

        users_deposit_addresses = related_users_addresses(transaction)
        return unless users_deposit_addresses.any?

        transaction_deposits = BitcoinDeposit.where(txid: txid)

        old_confirmations = transaction_deposits
          .select(:confirmations)
          .first
        old_confirmations &&= old_confirmations.confirmations
        existent = !old_confirmations.nil?

        deposits = transaction_deposits(users_deposit_addresses, transaction)

        if existent
          transaction_deposits.update(confirmations: confirmations)
          was_confirmed = existent && old_confirmations > 0

          # Transaction wasn't confirmed and now it is,
          # decrement user unconfirmed balance
          if !was_confirmed && confirmations > 0
            User.decrement_unconfirmed_balances(deposits)
          end
        else
          transaction['vout'].each do |details|
            address = details['scriptPubKey']['addresses'].first
            next unless users_deposit_addresses.include?(address)

            value = details['value'].abs * SATOSHI_BTC

            BitcoinDeposit.create(
              txid: txid,
              index: details['n'],
              address: address,
              amount: value,
              confirmations: confirmations,
              created_at: Time.now.utc,
            )
          end

          BitcoinDepositAddress.update_totals(deposits)
          User.increment_balances(deposits)

          if confirmations.zero?
            User.increment_unconfirmed_balances(deposits)
          end
        end
      end

      def self.transaction_deposits(user_addresses, transaction)
        transaction['vout'].reduce(Hash.new(0)) do |deposits, details|
          address = details['scriptPubKey']['addresses'].first

          next deposits unless user_addresses.include?(address)

          value = details['value'].abs * SATOSHI_BTC
          deposits[address] += value

          deposits
        end
      end
      private_class_method :transaction_deposits

      def self.related_users_addresses(transaction)
        all_addresses = transaction['vout'].map do |vout|
          next unless (key = vout['scriptPubKey'])
          key['addresses'].first
        end

        BitcoinDepositAddress
          .where(address: all_addresses)
          .select_map(:address)
      end
      private_class_method :related_users_addresses
    end
  end
end
