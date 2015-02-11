module Auth
  # This module holds all of the web controllers.
  module Controllers
    autoload :Base, 'auth/controllers/base'
    autoload :Sessions, 'auth/controllers/sessions'
    autoload :Users, 'auth/controllers/users'
  end
end
