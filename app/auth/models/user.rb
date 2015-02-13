module Auth
  module Models
    # This model represents a user.
    class User < ActiveRecord::Base
      self.table_name = 'users'

      has_many :sessions

      validates :name, presence: true
      validates :email, presence: true, uniqueness: true

      validates :password_salt, presence: true
      validates :password_hash, presence: true

      def as_json(opts = {})
        super(opts.merge(except: %w(password_salt password_hash created_at updated_at)))
      end
    end
  end
end
