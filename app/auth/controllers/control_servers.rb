module Auth
  module Controllers
    # This controller doesn't expose any routes, but is used as a base for the
    # rest of the application's controllers.
    class ControlServers < Base
      helpers { include Services::ControlServers }

      post '/control_servers/?' do
        status 201
        uuid, port = parse_json(req_body).values_at('uuid', 'port')
        create(uuid, request.ip, port).to_json
      end

      put '/control_servers/:uuid/?' do |uuid|
        status 200
        update(uuid, parse_json(req_body).merge('ip' => request.ip))
        read(uuid).to_json
      end

      post '/control_servers/:uuid/alert/?' do |uuid|
        status 201
        notify_users(uuid, parse_json(req_body))
        {}.to_json
      end

      get '/control_servers/exists/?' do
        begin
          status 200
          Services::ControlServers.for_ip(request.ip).to_json
        rescue Errors::NoSuchModel
          status 404
        end
      end
    end
  end
end
