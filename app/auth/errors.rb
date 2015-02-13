module Auth
  # This module holds all of the application errors.
  module Errors
    # Never raised, but used as a catch all for application specific errors.
    BaseError = Class.new(StandardError)

    # Raised when bad options are passed to create or update a model.
    BadModelOptions = Class.new(BaseError)

    # Raised on model creation when a unqieue attribute on that model already
    # exists in the database.
    ConflictingModelOptions = Class.new(BaseError)

    # Raised when an invalid model is referenced.
    NoSuchModel = Class.new(BaseError)

    # Raised when JSON cannot be parsed.
    MalformedRequestError = Class.new(BaseError)

    # Raised when a bad password is given.
    BadPassword = Class.new(BaseError)

    # Raised a user needs to be logged in but isn't.
    AuthError = Class.new(BaseError)
  end
end
