module Auth
  module Services
    # This service handles the CRUD lifecycle for users.
    module Users
      module_function

      def create(hash)
        name, email, password = hash.values_at('name', 'email', 'password')
        fail Errors::BadModelOptions, 'No password given' if password.blank?
        fail Errors::ConflictingModelOptions, "User with email '#{email}' exists" if exists?(email)
        wrap_active_record_errors do
          salt = generate_salt
          password_hash = hash_password(salt + password)
          Models::User.create!(
            name: name, email: email, password_hash: password_hash, password_salt: salt
          ).as_json
        end
      end

      def read(email)
        get_user(email).as_json
      end

      def update(email, hash)
        wrap_active_record_errors { get_user(email).update_attributes!(hash) }
      end

      def destroy(email)
        get_user(email).destroy!
      end

      def exists?(email)
        Models::User.exists?(email: email)
      end

      def get_user(email)
        Models::User.find_by(email: email).tap do |user|
          fail Errors::NoSuchModel, "Unable to find user with email '#{email}'" if user.nil?
        end
      end

      def wrap_active_record_errors
        yield
      rescue ActiveRecord::UnknownAttributeError, ActiveRecord::RecordInvalid => ex
        raise Errors::BadModelOptions, ex
      end

      def generate_salt
        SecureRandom.base64
      end

      def hash_password(pass)
        Digest::SHA1.hexdigest(pass)
      end
    end
  end
end
