require 'bcrypt'

module Services
  module Users
    module Create
      def self.perform(attrs)
        User.create(username: attrs[:username]) do |user|
          user.salt = BCrypt::Engine.generate_salt
          user.encrypted_password = BCrypt::Engine.hash_secret(
            attrs[:password], user.salt
          )
        end
      end
    end
  end
end
