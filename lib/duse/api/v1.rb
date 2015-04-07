require 'duse/api/endpoints/routes'
require 'duse/api/endpoints/secrets'
require 'duse/api/endpoints/user_token'
require 'duse/api/endpoints/user_confirmation'
require 'duse/api/endpoints/password_reset'
require 'duse/api/endpoints/users'

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
