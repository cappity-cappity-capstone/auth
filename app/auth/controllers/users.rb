module Auth
  module Controllers
    # This controller doesn't expose any routes, but is used as a base for the
    # rest of the application's controllers.
    class Users < Base
      post '/users/?' do
        status 201
        Services::Users.create(parse_json(req_body)).to_json
      end

      put '/users/:id/?' do |id|
        status 200
        Services::Users.update(email_for_id(id), parse_json(req_body)).to_json
      end

      delete '/users/:id/?' do |id|
        status 204
        Services::Users.destroy(email_for_id(id)).to_json
      end

      def email_for_id(id)
        Models::User.where(id: id).first.try(&:email)
      end
    end
  end
end
