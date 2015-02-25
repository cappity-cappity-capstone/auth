# This module acts as the top-level namespace for the application.
module Auth
  autoload :Config, 'auth/config'
end

Bundler.require(:default, (ENV['APP_ENV'] || 'development').to_sym)

# This module acts as the top-level namespace for the application.
module Auth
  autoload :Controllers, 'auth/controllers'
  autoload :Errors, 'auth/errors'
  autoload :Models, 'auth/models'
  autoload :Services, 'auth/services'
end
