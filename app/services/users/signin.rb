require 'bcrypt'

module Services
  module Users
    module Signin
      def self.perform(username, password)
        user = User.where(username: username).first

        user if user && password_match?(user, password)
      end

      def self.password_match?(user, password)
        secret = BCrypt::Engine.hash_secret(password, user.salt)

        user.encrypted_password == secret
      end
      private_class_method :password_match?
    end
  end
end
