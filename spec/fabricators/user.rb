Fabricator(:user) do
  username { sequence(:username) { |i| "user-#{i}" } }
  balance 0
  unconfirmed_balance 0
  encrypted_password 'test'
  salt 'test'
end
