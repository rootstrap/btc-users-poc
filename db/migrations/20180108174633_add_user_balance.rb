Sequel.migration do
  up do
    add_column(:users, :balance, :Bignum)
    add_column(:users, :unconfirmed_balance, :Bignum)
    from(:users).update(balance: 0, unconfirmed_balance: 0)

    alter_table(:users) do
      set_column_not_null(:balance)
      set_column_not_null(:unconfirmed_balance)
    end
  end

  down do
    drop_column(:users, :unconfirmed_balance)
  end
end
