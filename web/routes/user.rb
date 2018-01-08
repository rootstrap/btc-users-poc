module Routes
  class User < Cuba
    define do
      require_login!

      on(get, 'transactions') do
        transactions = Services::BitcoinDeposits::UserDeposits
          .perform(current_user)

        render('transactions/index', transactions: transactions)
      end

      on('addresses') do
        on(post) do
          Services::Bitcoin::CreateDepositAddress.perform(
            current_user
          )

          redirect_to('/user/addresses')
        end

        on(get) do
          addresses = BitcoinDepositAddress.where(
            user_id: current_user.id
          ).all

          render('addresses/index', addresses: addresses)
        end
      end
    end
  end
end
