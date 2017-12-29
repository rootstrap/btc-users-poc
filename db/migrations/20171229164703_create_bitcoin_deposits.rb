Sequel.migration do
  change do
    create_table(:bitcoin_deposit_addresses) do
      primary_key(:address, String)

      foreign_key(:user_id, :users, null: false)

      column(:created_at, DateTime, null: false)
    end

    create_table(:bitcoin_deposits) do
      primary_key(:id, String)
      foreign_key(:address, :bitcoin_deposit_addresses, type: String, null: false)

      column(:amount, :Bignum, null: false)
      column(:created_at, DateTime, null: false)
    end
  end
end
