require 'api/middlewares/v1_switch'
require 'api/middlewares/authentication'
require 'api/v1'

module Duse
  module API
    class App
      attr_accessor :app

      def initialize
        @app = Rack::Builder.app do
          use Rack::Cors do
            allow do
              origins '*'
              resource '*', headers: :any, methods: [:get, :post, :patch, :put, :delete]
            end
          end
          use Authentication
          use V1Switch
          run V1.new
        end
      end

      def call(env)
        app.call(env)
      end
    end
  end
end

