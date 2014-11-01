require 'grape'
require 'grape-swagger'
require 'data_mapper'
require 'warden'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite::memory:')
require 'models/user'
require 'models/secret'
require 'models/secret_part'
require 'models/share'
DataMapper.finalize.auto_upgrade!
DataMapper::Model.raise_on_save_failure = true

require 'api/helpers'
require 'api/secrets'

module API
  class API < Grape::API
    version 'v1', using: :path

    rescue_from DataMapper::ObjectNotFoundError do
      rack_response({message: '404 Not found'}.to_json, 404)
    end

    rescue_from DataMapper::SaveFailureError do |e|
      rack_response({message: e.resource.errors.full_messages}.to_json, 422)
    end

    rescue_from :all do |exception|
      # lifted from https://github.com/rails/rails/blob/master/actionpack/lib/action_dispatch/middleware/debug_exceptions.rb#L60
      # why is this not wrapped in something reusable?
      trace = exception.backtrace

      message = "\n#{exception.class} (#{exception.message}):\n"
      message << exception.annoted_source_code.to_s if exception.respond_to?(:annoted_source_code)
      message << "  " << trace.join("\n  ")

      API.logger.add Logger::FATAL, message
      rack_response({message: '500 Internal Server Error'}, 500)
    end

    use Warden::Manager do |config|
      config.default_scope = :api

      config.scope_defaults(
        :api,
        strategies: [:api_token],
        store: false,
        action: "unauthenticated_api"
      )
    end

    format :json
    content_type :txt, "text/plain"

    helpers APIHelpers

    mount Secrets

    add_swagger_documentation
  end
end
