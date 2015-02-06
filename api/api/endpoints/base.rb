require 'duse/errors'
require 'duse/authorization'
require 'api/endpoints/helpers'
require 'api/warden_strategies/api_token'
require 'api/warden_strategies/password'

module Duse
  module Endpoints
    class Base < Sinatra::Base
      enable :logging
      enable :dump_errors
      disable :show_exceptions # disable middleware displaying errors as html

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

