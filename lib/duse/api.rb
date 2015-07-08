require 'duse/api/v1_switch'
require 'duse/api/authentication'
require 'duse/api/cors'
require 'duse/api/v1/routes'
require 'duse/api/config'
require 'duse/api/common_logger'

module Duse
  module API
    class App
      def initialize
        @app = Rack::Builder.app do
          use CommonLogger, Logger.new(STDOUT)
          use Cors
          use Authentication
          use V1Switch
          run V1::Routes
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

