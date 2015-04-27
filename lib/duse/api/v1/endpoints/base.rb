require 'sinatra/base'
require 'sinatra/namespace'
require 'sinatra/json'
require 'sinatra/activerecord'

require 'duse/api/errors'
require 'duse/api/authorization'
require 'duse/api/v1/endpoints/helpers'
require 'duse/api'

module Duse
  module API
    module Endpoints
      class Base < Sinatra::Base
        set :database, ENV['DATABASE_URL']
        set :database_extras, { pool: 5, timeout: 3000, encoding: 'unicode' }
        enable :dump_errors
        disable :raise_errors
        disable :show_exceptions # disable middleware displaying errors as html

        helpers Helpers
        helpers Sinatra::JSON
        register Sinatra::Namespace
        register Sinatra::ActiveRecordExtension

        error JSON::ParserError do
          halt 400, { message: 'Invalid json' }.to_json
        end

        error UserNotConfirmed do
          env['warden'].custom_failure!
          halt 401, { message: 'User not confirmed' }.to_json
        end

        error InvalidAuthorization do
          halt 403, { message: 'You are not authorized to access a resource' }.to_json
        end

        error NotFound do
          halt 404
        end

        not_found do
          { message: 'Not found' }.to_json
        end

        error ValidationFailed do
          halt 422, env['sinatra.error'].message
        end

        error do
          Raven.capture_exception env['sinatra.error']
          halt 500, JSON.generate(message: 'Whoops, an error occured in duse')
        end
      end
    end
  end
end

