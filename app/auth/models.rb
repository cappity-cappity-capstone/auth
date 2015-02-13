module Auth
  # This module holds all of the database models.
  module Models
    autoload :User, 'auth/models/user'
    autoload :Session, 'auth/models/session'
  end
end
