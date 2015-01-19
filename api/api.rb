require 'duse/errors'
require 'duse/entity_errors'
require 'duse/authorization'
require 'duse/encryption'
require 'duse/json/json_validator'
require 'duse/json/json_extractor'
require 'duse/json/json_models'
require 'api/facades/secret'
require 'api/validations/secret_validator'
require 'api/warden_strategies/api_token'
require 'api/warden_strategies/password'
require 'api/endpoints/helpers'
require 'api/endpoints/secrets'
require 'api/endpoints/users'
require 'api/endpoints/user_token'
require 'api/endpoints/routes'
require 'api/authorization/secret'
require 'api/json_views/secret'
require 'api/json_views/user'
require 'api/json/secret'
require 'api/json/user'

module Duse
  class API < Grape::API
    version 'v1', using: :path

    rescue_from DataMapper::ObjectNotFoundError do
      rack_response({ message: 'Not found' }.to_json, 404)
    end

    rescue_from Duse::InvalidAuthorization do
      rack_response({ message: 'Forbidden' }.to_json, 403)
    end

    rescue_from Duse::ValidationFailed do |e|
      rack_response(e.message, 422)
    end

    rescue_from :all do |exception|
      # lifted from https://github.com/rails/rails/blob/master/actionpack/lib/action_dispatch/middleware/debug_exceptions.rb#L60
      # why is this not wrapped in something reusable?
      trace = exception.backtrace

      message = "\n#{exception.class} (#{exception.message}):\n"
      message << exception.annoted_source_code.to_s if exception.respond_to?(:annoted_source_code)
      message << '  ' << trace.join("\n  ")

      API.logger.add Logger::FATAL, message
      rack_response({ message: '500 Internal Server Error' }.to_json, 500)
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

    format :json
    content_type :txt, 'text/plain'

    helpers Endpoints::Helpers

    mount Endpoints::Routes
    mount Endpoints::Secrets
    mount Endpoints::Users
    mount Endpoints::UserToken
  end
end
