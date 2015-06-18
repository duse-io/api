module Duse
  module API
    class ValidationFailed < StandardError; end
    class NotFound < StandardError; end
    class UserNotConfirmed < StandardError; end

    class MalformedJSON < StandardError
      def initialize(msg = 'Invalid json')
        super(msg)
      end
    end

    class AlreadyConfirmed < StandardError
      def initialize(msg = 'Account already confirmed')
        super(msg)
      end
    end
  end
end

