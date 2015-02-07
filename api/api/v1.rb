require 'api/endpoints/secrets'
require 'api/endpoints/users'
require 'api/endpoints/routes'

module Duse
  module API
    class V1
      attr_accessor :app

      def initialize
        @app = Rack::Cascade.new([
          Endpoints::Routes,
          Endpoints::Secrets,
          Endpoints::Users
        ])
      end

      def call(env)
        app.call(env)
      end
    end
  end
end
