module Auth
  module Models
    # This model represents a user.
    class User < ActiveRecord::Base
      self.table_name = 'users'

      validates :name, presence: true
      validates :email, presence: true, uniqueness: true

      validates :password_salt, presence: true
      validates :password_hash, presence: true
    end
  end
end
