require 'api/endpoints/routes'
require 'api/endpoints/secrets'
require 'api/endpoints/user_token'
require 'api/endpoints/user_confirmation'
require 'api/endpoints/password_reset'
require 'api/endpoints/users'

module Duse
  module API
    class V1
      def initialize
        @app = Rack::Cascade.new([
          Endpoints::Routes,
          Endpoints::Secrets,
          Endpoints::UserToken,
          Endpoints::UserConfirmation,
          Endpoints::PasswordReset,
          Endpoints::Users
        ])
      end

      def call(env)
        @app.call(env)
      end
    end
  end
end
