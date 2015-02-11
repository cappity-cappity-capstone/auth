module Auth
  # This module holds all of the application services.
  module Services
    autoload :Base, 'auth/services/base'
    autoload :Users, 'auth/services/users'
  end
end
