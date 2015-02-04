module Duse
  module Endpoints
    class Base < Sinatra::Base
      helpers Endpoints::Helpers
      helpers Sinatra::JSON
      register Sinatra::Namespace

      before do
        content_type 'application/json'
      end

      error ActiveRecord::RecordNotFound do
        Rack::Response.new({ message: 'Not found' }.to_json, 404)
      end

      error Duse::InvalidAuthorization do
        Rack::Response.new({ message: 'Forbidden' }.to_json, 403)
      end

      error Duse::ValidationFailed do |e|
        Rack::Response.new(e.message, 422)
      end

      error do |exception|
        # lifted from https://github.com/rails/rails/blob/master/actionpack/lib/action_dispatch/middleware/debug_exceptions.rb#L60
        # why is this not wrapped in something reusable?
        trace = exception.backtrace

        message = "\n#{exception.class} (#{exception.message}):\n"
        message << exception.annoted_source_code.to_s if exception.respond_to?(:annoted_source_code)
        message << '  ' << trace.join("\n  ")

        API.logger.add Logger::FATAL, message
        Rack::Response.new({ message: '500 Internal Server Error' }.to_json, 500)
      end

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
    end
  end
end
