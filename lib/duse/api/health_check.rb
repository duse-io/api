require 'rack/response'

module Duse
  module API
    class HealthCheck
      def call(env)
        Rack::Response.new(['OK'])
      end
    end
  end
end

