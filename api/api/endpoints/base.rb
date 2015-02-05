module Duse
  module Endpoints
    class Base < Sinatra::Base
      enable  :logging
      enable  :raise_errors    # don't capture errors throw them up the stack
      disable :show_exceptions # disable middleware displaying errors as html
      disable :dump_errors

      helpers Helpers
      helpers Sinatra::JSON
      register Sinatra::Namespace
      register Sinatra::ActiveRecordExtension

      error JSON::ParserError do
        halt 400
      end

      error Duse::InvalidAuthorization do
        halt 403
      end

      error ActiveRecord::RecordNotFound do
        halt 404
      end

      error Duse::ValidationFailed do
        halt 422, env['sinatra.error'].message
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

