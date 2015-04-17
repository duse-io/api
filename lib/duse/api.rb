require 'duse/api/v1_switch'
require 'duse/api/authentication'
require 'duse/api/cors'
require 'duse/api/v1'
require 'duse/api/config'

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

    extend self

    def config
      @config ||= Config.new(
        sentry_dsn: ENV['SENTRY_DSN'],
        secret_key: ENV['SECRET_KEY'],
        ssl: ENV['SSL'],
        host: ENV['HOST'],
        email: ENV['EMAIL']
      )
    end
  end
end

