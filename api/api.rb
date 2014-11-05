require 'grape'
require 'grape-swagger'
require 'data_mapper'
require 'warden'

puts ENV['DATABASE_URL']
DataMapper.setup(:default, ENV['DATABASE_URL'])
require 'models/user'
require 'models/secret'
require 'models/secret_part'
require 'models/share'
DataMapper.finalize.auto_upgrade!
DataMapper::Model.raise_on_save_failure = true

require 'api/helpers'
require 'api/secrets'
require 'api/users'

module API
  class API < Grape::API
    version 'v1', using: :path

    rescue_from DataMapper::ObjectNotFoundError do
      rack_response({message: '404 Not found'}.to_json, 404)
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
      config.failure_app = -> env{ [401, {'Content-Length' => '0'}, ['']] }

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
    mount Users

    add_swagger_documentation
  end
end

class APITokenStrategy < ::Warden::Strategies::Base
  def valid?
    !api_token.blank?
  end

  def authenticate!
    user = User.first(api_token: api_token)
    if user.nil?
      fail! 'Unauthenticated'
    else
      success! user
    end
  end

  private

  def api_token
    env['HTTP_AUTHORIZATION']
  end
end

Warden::Strategies.add(:api_token, APITokenStrategy)
