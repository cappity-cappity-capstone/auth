module Auth
  module Controllers
    # This controller doesn't expose any routes, but is used as a base for the
    # rest of the application's controllers.
    class Base < Sinatra::Base
      set :raise_errors, false
      set :show_exceptions, false

      before { content_type :json }

      error do |err|
        case err
        when Errors::BadModelOptions
          status 400
        when Errors::NoSuchModel
          status 404
        when Errors::ConflictingModelOptions
          status 409
        else
          status 500
        end

        { class: err.class.name, message: err.message }.to_json
      end

      def parse_json(body)
        JSON.parse(body)
      rescue JSON::JSONError => ex
        raise Errors::MalformedRequestError, ex
      end

      def req_body
        request.body.tap(&:rewind).read
      end
    end
  end
end