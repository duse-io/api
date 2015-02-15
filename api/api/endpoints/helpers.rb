module Duse
  module Endpoints
    module Helpers
      def current_user
        env['warden'].user
      end

      def authenticate!(scope = :api_token)
        env['warden'].authenticate!(scope)
      end

      def authenticate(scope = :api_token)
        env['warden'].authenticate(scope)
      end

      def authenticated?(scope = :api_token)
        env['warden'].authenticated?(scope)
      end

      def request_body
        result = request.body.gets
        request.body.rewind
        result
      end
    end
  end
end

