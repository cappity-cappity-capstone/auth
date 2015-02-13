module Auth
  module Controllers
    # This controller doesn't expose any routes, but is used as a base for the
    # rest of the application's controllers.
    class Base < Sinatra::Base
      set :raise_errors, false
      set :show_exceptions, false

      before { content_type :json }

      error do |err|
        case err
        when Errors::BadModelOptions
          status 400
        when Errors::BadPassword
          status 401
        when Errors::AuthError
          status 403
        when Errors::NoSuchModel
          status 404
        when Errors::ConflictingModelOptions
          status 409
        else
          status 500
        end

        { class: err.class.name, message: err.message }.to_json
      end

      def logged_in_user
        @logged_in_user ||= Services::Users.for_session(request.cookies['session_key'])
      end

      def ensure_user_logged_in!(id)
        if logged_in_user.nil?
          fail Errors::AuthError, 'No user logged in'
        elsif logged_in_user.id != id.to_i
          fail Errors::AuthError, %(Logged in user's id "#{logged_in_user.id}"
                                    does not match expected id "#{id}")
        end
      end

      def parse_json(body)
        JSON.parse(body)
      rescue JSON::JSONError => ex
        raise Errors::MalformedRequestError, ex
      end

      def req_body
        request.body.tap(&:rewind).read
      end
    end
  end
end
