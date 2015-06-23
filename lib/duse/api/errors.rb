module Duse
  module API
    class APIError < StandardError
      attr_reader :status_code

      def initialize(msg, status_code)
        super(msg)
        @status_code = status_code
      end

      def json
        { message: message }.to_json
      end
    end

    class ValidationFailed < APIError
      def initialize(msg, status_code = 422)
        super(msg, status_code)
      end

      def json
        message
      end
    end

    class MalformedJSON < APIError
      def initialize(msg = 'Invalid json', status_code = 400)
        super(msg, status_code)
      end
    end

    class AlreadyConfirmed < APIError
      def initialize(msg = 'Account already confirmed', status_code = 400)
        super(msg, status_code)
      end
    end

    class InvalidAuthorization < APIError
      def initialize(msg = 'You are not authorized to access a resource', status_code = 403)
        super(msg, status_code)
      end
    end

    class UserNotConfirmed < APIError
      def initialize(msg = 'User not confirmed', status_code = 401)
        super(msg, status_code)
      end
    end

    class NotFound < APIError
      def initialize(msg = 'Not found', status_code = 404)
        super(msg, status_code)
      end
    end
  end
end

