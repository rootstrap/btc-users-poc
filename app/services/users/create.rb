require 'bcrypt'

module Services
  module Users
    module Create
      def self.perform(attrs)
        user_attributes = {
          username: attrs[:username],
          balance: 0,
          unconfirmed_balance: 0
        }

        User.create(user_attributes) do |user|
          user.salt = BCrypt::Engine.generate_salt
          user.encrypted_password = BCrypt::Engine.hash_secret(
            attrs[:password], user.salt
          )
        end
      end
    end
  end
end
