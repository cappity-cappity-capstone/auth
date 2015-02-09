module Auth
  # This module holds all of the web controllers.
  module Controllers
    autoload :Base, 'auth/controllers/base'
    autoload :Users, 'auth/controllers/users'
  end
end
