require 'encryption'
require 'warden_strategies/api_token'
require 'warden_strategies/password'
require 'validations/secret_validator'
require 'json/json_validator'
require 'json/json_extractor'
require 'json/json_models'
require 'authorization/secret_authorization'
require 'api/entities'
require 'api/helpers'
require 'api/secrets'
require 'api/users'

module API
  class API < Grape::API
    version 'v1', using: :path

    rescue_from DataMapper::ObjectNotFoundError do
      rack_response({ message: '404 Not found' }.to_json, 404)
    end

    rescue_from Duse::InvalidAuthorization do
      rack_response({ message: '403 Forbidden' }.to_json, 403)
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

    helpers APIHelpers

    desc 'API Root'
    get do
      {
        secrets_url: '/secrets',
        users_url:   '/users'
      }
    end

    mount Secrets
    mount Users
  end
end
