module Auth
  # This module holds all of the application services.
  module Services
    autoload :Base, 'auth/services/base'
    autoload :Sessions, 'auth/services/sessions'
    autoload :Users, 'auth/services/users'
  end
end
