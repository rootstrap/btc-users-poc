Sequel.migration do
  up do
    create_table(:users) do
      primary_key(:id)

      column(:username, String, null: false)
      column(:encrypted_password, String, null: false)
      column(:salt, String, null: false)

      index(:username, unique: true)
    end
  end

  down do
    drop_table(:users)
  end
end
