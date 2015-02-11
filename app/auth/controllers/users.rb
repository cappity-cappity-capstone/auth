module Auth
  module Controllers
    # This controller doesn't expose any routes, but is used as a base for the
    # rest of the application's controllers.
    class Users < Base
      helpers { include Services::Users }

      post '/users/?' do
        status 201
        create(parse_json(req_body)).to_json
      end

      put '/users/:id/?' do |id|
        ensure_user_logged_in! id
        status 200
        attrs = parse_json(req_body).except('password_hash', 'password_salt')
        update(id, attrs).to_json
      end

      delete '/users/:id/?' do |id|
        ensure_user_logged_in! id
        status 204
        destroy(id).to_json
      end
    end
  end
end
