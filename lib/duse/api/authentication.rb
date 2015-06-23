require 'duse/api/api_token_strategy'
require 'duse/api/password_strategy'

module Duse
  module API
    class Authentication
      def initialize(app)
        @app = Warden::Manager.new(app) do |config|
          config.default_scope = :api
          config.failure_app = -> _ { [401, { 'Content-Length' => '0' }, ['']] }
          config.scope_defaults(
            :password,
            strategies: [:password],
            store: false,
            action: 'unauthenticated'
          )

          config.scope_defaults(
            :api,
            strategies: [:api_token],
            store: false,
            action: 'unauthenticated'
          )
        end
      end

      def call(env)
        @app.call(env)
      end
    end
  end
end

