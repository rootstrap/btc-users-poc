class BitcoinDepositAddress < Sequel::Model
  unrestrict_primary_key
  plugin :validation_helpers

  many_to_one :user

  def self.update_totals(deposits)
    deposits.each do |address, amount|
      next if amount.zero?

      BitcoinDepositAddress
        .where(address: address)
        .update(:total => Sequel.+(:total,  amount))
    end
  end

  def validate
    validates_unique(:address)
  end
end
