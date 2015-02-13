module Auth
  module Services
    # This module holds common methods used in each service.
    module Base
      def self.included(klass)
        klass.extend(self)
      end

      def wrap_active_record_errors
        yield
      rescue ActiveRecord::UnknownAttributeError, ActiveRecord::RecordInvalid => ex
        raise Errors::BadModelOptions, ex
      end
    end
  end
end
