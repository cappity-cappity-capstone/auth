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
        attrs = parse_json(req_body).except('password_hash', 'password_salt')
        Services::Users.update(id, attrs).to_json
      end

      delete '/users/:id/?' do |id|
        status 204
        Services::Users.destroy(id).to_json
      end
    end
  end
end
