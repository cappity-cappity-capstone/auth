module Auth
  module Models
    # This model represents a user's session.
    class Session < ActiveRecord::Base
      self.table_name = 'sessions'

      belongs_to :user

      scope :active, -> { where('expires_on > ?', Time.now) }

      validates :key, presence: true
      validates :expires_on, presence: true
      validates :user_id, presence: true

      validate :user_associated?

      def as_json(opts = {})
        super(opts.merge(except: %w(created_at updated_at)))
      end

      def expired?
        Time.now < expires_on
      end

      def user_associated?
        errors.add(:user_id, 'is not a valid user id') unless User.exists?(id: user_id)
      end
    end
  end
end
