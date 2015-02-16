module Auth
  module Controllers
    # This controller doesn't expose any routes, but is used as a base for the
    # rest of the application's controllers.
    class Users < Base
      helpers { include Services::Users }

      get '/users/logged_in/?' do
        fail Errors::NoSuchModel, 'No user is logged in' if logged_in_user.nil?
        status 200
        logged_in_user.to_json
      end

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

      post '/users/:id/associate/?' do |id|
        ensure_user_logged_in! id
        status 201
        control_server = Services::ControlServers.for_ip(request.ip)
        associate_control_server(logged_in_user.id, control_server['uuid'])
      end
    end
  end
end
