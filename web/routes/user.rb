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
        on(':address') do |address|
          on(get, root) do
            user_address = BitcoinDepositAddress.find(address: address)
            transactions = Services::BitcoinDeposits::AddressDeposits
              .perform(address)

            render('/addresses/show', address: user_address,
                                      transactions: transactions)
          end
        end

        on(post) do
          address = Services::Bitcoin::CreateDepositAddress.perform(
            current_user
          )

          redirect_to("/user/addresses/#{address[:address]}")
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
