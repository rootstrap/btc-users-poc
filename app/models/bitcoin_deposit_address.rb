class BitcoinDepositAddress < Sequel::Model
  unrestrict_primary_key
  plugin :validation_helpers

  def validate
    validates_unique(:address)
  end
end
