module Auth
  module Services
    # This service creates and uptase control servers
    module ControlServers
      include Base

      module_function

      def create(uuid, ip, port)
        if Models::ControlServer.exists?(uuid: uuid)
          fail Errors::ConflictingModelOptions, "UUID already exists #{uuid}"
        end

        wrap_active_record_errors do
          Models::ControlServer.create!(uuid: uuid, ip: ip, port: port).as_json
        end
      end

      def read(uuid)
        get_control_server(uuid).as_json
      end

      def update(uuid, attrs)
        control_server = get_control_server(uuid)

        wrap_active_record_errors do
          control_server.update_attributes!(attrs).as_json
        end
      end

      def notify_users(uuid, data)
        control_server = get_control_server(uuid)

        alert = data['alert']

        fail Errors::MalformedRequestError, "Bad alert: #{data}" if alert.nil? || alert['name'].nil?

        control_server.users.each do |user|
          Services::SendEmail.send(
            user.email,
            "Alert fired for #{alert['name']}!",
            "All related devices have been turned off or locked."
          )
        end
      end

      def for_ip(ip)
        Models::ControlServer.find_by(ip: ip).tap do |control_server|
          fail Errors::NoSuchModel, "No such ip: #{ip}" unless control_server
        end.as_json
      end

      def get_control_server(uuid)
        Models::ControlServer.find_by(uuid: uuid).tap do |control_server|
          fail Errors::NoSuchModel, "No such uuid: #{uuid}" unless control_server
        end
      end
    end
  end
end
