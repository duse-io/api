require 'api/middlewares/v1_switch'
require 'api/v1'
require 'api/warden_strategies/api_token'
require 'api/warden_strategies/password'

module Duse
  module API
    class App
      ERROR_MESSAGE = JSON.generate({ message: 'Whoops, an error occured in duse' })

      attr_accessor :app

      def initialize
        @app = Rack::Builder.app do
          use V1Switch

          use Warden::Manager do |config|
            config.default_scope = :api
            config.failure_app = -> _env { [401, { 'Content-Length' => '0' }, ['']] }
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

          run V1.new
        end
      end

      def call(env)
        app.call(env)
      rescue
        [500, {'Content-Type' => 'application/json'}, ERROR_MESSAGE]
      end
    end
  end
end

