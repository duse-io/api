require 'api/middlewares/v1_switch'
require 'api/middlewares/authentication'
require 'api/middlewares/cors'
require 'api/v1'

module Duse
  module API
    class App
      def initialize
        @app = Rack::Builder.app do
          use Cors
          use Authentication
          use V1Switch
          run V1.new
        end
      end

      def call(env)
        @app.call(env)
      end
    end
  end
end

