class User < Sequel::Model
  plugin :validation_helpers

  def validate
    validates_unique(:username)
  end
end
