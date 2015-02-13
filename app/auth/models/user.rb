module Auth
  module Models
    # This model represents a user.
    class User < ActiveRecord::Base
      self.table_name = 'users'

      has_many :sessions
      belongs_to :control_server

      validates :name, presence: true
      validates :email, presence: true, uniqueness: true

      validates :password_salt, presence: true
      validates :password_hash, presence: true

      validate :control_server_associated?

      def as_json(opts = {})
        super(opts.merge(
          except: %w(password_salt password_hash created_at updated_at control_server_id),
          include: :control_server
        ))
      end

      def control_server_associated?
        return if control_server_id.nil? || ControlServer.exists?(id: control_server_id)
        errors.add(:control_server_id, 'is not a valid control server id')
      end
    end
  end
end
