class User < Sequel::Model
  plugin :validation_helpers

  def self.increment_unconfirmed_balances(deposits)
    addresses = BitcoinDepositAddress.select(:user_id).limit(1)

    deposits.each do |address, amount|
      next if amount.zero?

      User
        .where(id: addresses.where(address: address))
        .update(unconfirmed_balance: Sequel.+(:unconfirmed_balance, amount))
    end
  end

  def self.decrement_unconfirmed_balances(deposits)
    addresses = BitcoinDepositAddress.select(:user_id).limit(1)

    deposits.each do |address, amount|
      next if amount.zero?

      User
        .where(id: addresses.where(address: address))
        .update(unconfirmed_balance: Sequel.-(:unconfirmed_balance, amount))
    end
  end

  def self.increment_balances(deposits)
    addresses = BitcoinDepositAddress.select(:user_id).limit(1)

    deposits.each do |address, amount|
      next if amount.zero?

      User
        .where(id: addresses.where(address: address))
        .update(balance: Sequel.+(:balance, amount))
    end
  end

  def validate
    validates_unique(:username)
  end
end
