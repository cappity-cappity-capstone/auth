module Auth
  # This module holds all of the database models.
  module Models
    autoload :ControlServer, 'auth/models/control_server'
    autoload :User, 'auth/models/user'
    autoload :Session, 'auth/models/session'
  end
end
