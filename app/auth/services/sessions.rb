module Auth
  module Services
    # This service coordinates user sessions.
    module Sessions
      include Base

      module_function

      def create(email, password, expires)
        fail Errors::NoSuchModel, "No user for email: #{email}" unless Users.exists?(email)

        user = Users.authenticate(email, password)
        fail Errors::BadPassword, 'Bad email/password combination' unless user

        wrap_active_record_errors do
          Models::Session.create(user_id: user.id, expires_on: expires, key: generate_key).as_json
        end
      end

      def expire(key)
        session = Models::Session.find_by(key: key)
        fail Errors::NoSuchModel, "Invalid session key: '#{key}'" unless session
        wrap_active_record_errors { session.update_attributes!(expires_on: Time.now) }
      end

      def generate_key
        SecureRandom.base64
      end
    end
  end
end
