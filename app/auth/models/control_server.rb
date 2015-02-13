module Auth
  module Models
    # This model represents a user.
    class ControlServer < ActiveRecord::Base
      self.table_name = 'control_servers'

      has_many :users

      validates :uuid, presence: true
      validates :ip, presence: true
      validates :port, presence: true

      validate :valid_ip?

      def as_json(opts = {})
        super(opts.merge(except: %w(created_at updated_at)))
      end

      private

      def valid_ip?
        normalized_ip = ip || ''
        conditions = [
          normalized_ip.split('.').all? { |num| num.to_i.between?(0, 255) },
          normalized_ip.match(/\A\d+(?:\.\d+){3}\z/)
        ]
        errors.add(:ip, 'is not a valid ip') unless conditions.all?
      end
    end
  end
end
