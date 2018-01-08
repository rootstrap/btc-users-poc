class BitcoinDeposit < Sequel::Model
  unrestrict_primary_key
  plugin :validation_helpers

  many_to_one :bitcoin_deposit_address, key: :address

  def validate
    validates_presence(:txid)
    validates_presence(:amount)
    validates_presence(:confirmations)
    validates_presence(:index)
    validates_presence(:created_at)
  end
end
