Fabricator(:bitcoin_deposit_address) do
  address { sequence(:address) { |n| "address-#{n}" } }
  user { Fabricate(:user) }
  created_at { Time.now.utc }
  total { rand }
end
