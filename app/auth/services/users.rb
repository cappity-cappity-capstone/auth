module Auth
  module Services
    # This service handles the CRUD lifecycle for users.
    module Users
      include Base

      module_function

      def create(hash)
        name, email, password = hash.values_at('name', 'email', 'password')
        fail Errors::BadModelOptions, 'No password given' if password.blank?
        fail Errors::ConflictingModelOptions, "User with email '#{email}' exists" if exists?(email)
        wrap_active_record_errors do
          salt = generate_salt
          password_hash = hash_password(salt, password)
          Models::User.create!(
            name: name, email: email, password_hash: password_hash, password_salt: salt
          ).as_json
        end
      end

      def read(id)
        get_user(id).as_json
      end

      def update(id, hash)
        user = get_user(id)
        email = hash['email']

        if (email != user.email) && exists?(email)
          fail Errors::ConflictingModelOptions, "A user with email '#{email}' already exists"
        end

        if hash['password'].present?
          hash['password_hash'] = hash_password(user.password_salt, hash.delete('password'))
        end

        wrap_active_record_errors { user.update_attributes!(hash) }
      end

      def destroy(id)
        get_user(id).destroy!
      end

      def authenticate(email, password)
        user = Models::User.find_by(email: email)
        return unless user && (user.password_hash == hash_password(user.password_salt, password))
        user
      end

      def for_session(key)
        Models::Session.active.includes(:user).find_by(key: key).try(:user)
      end

      def exists?(email)
        Models::User.exists?(email: email)
      end

      def get_user(id)
        Models::User.find_by(id: id).tap do |user|
          fail Errors::NoSuchModel, "Unable to find user with id '#{id}'" if user.nil?
        end
      end

      def generate_salt
        SecureRandom.base64
      end

      def hash_password(salt, pass)
        Digest::SHA1.hexdigest([salt, pass].join)
      end
    end
  end
end
