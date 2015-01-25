module Duse
  module Endpoints
    module Helpers
      def current_user
        env['warden'].user
      end

      def authenticate!(scope = :api_token)
        env['warden'].authenticate!(scope)
      end
    end
  end
end

