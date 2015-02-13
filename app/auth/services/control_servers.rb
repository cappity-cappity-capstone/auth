module Auth
  module Services
    # This service creates and uptase control servers
    module ControlServers
      include Base

      module_function

      def create(uuid, ip, port)
        if Models::ControlServer.exists?(uuid: uuid)
          fail Errors::ConflictingModelOptions, "UUID already exists #{uuid}"
        else
          wrap_active_record_errors do
            Models::ControlServer.create!(uuid: uuid, ip: ip, port: port).as_json
          end
        end
      end

      def update(uuid, attrs)
        control_server = Models::ControlServer.find_by(uuid: uuid)
        fail Errors::NoSuchModel, "No such uuid: #{uuid}" unless control_server
        wrap_active_record_errors do
          control_server.update_attributes!(attrs).as_json
        end
      end

      def for_ip(ip)
        control_server = Models::ControlServer.find_by(ip: ip)
        fail Errors::NoSuchModel, "No such ip: #{ip}" unless control_server
        control_server.as_json
      end
    end
  end
end
