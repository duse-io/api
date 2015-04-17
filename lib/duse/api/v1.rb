require 'duse/api/v1/endpoints/routes'
require 'duse/api/v1/endpoints/secrets'
require 'duse/api/v1/endpoints/user_token'
require 'duse/api/v1/endpoints/user_confirmation'
require 'duse/api/v1/endpoints/password_reset'
require 'duse/api/v1/endpoints/users'

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
