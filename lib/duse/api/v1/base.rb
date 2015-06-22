require 'sinatra/base'
require 'sinatra/activerecord'

require 'duse/api/errors'
require 'duse/api/authorization'
require 'duse/api/v1/helpers'
require 'duse/api'

module Duse
  module API
    module V1
      class Base < Sinatra::Base
        set :database, ENV['DATABASE_URL']
        set :database_extras, { pool: 5, timeout: 3000, encoding: 'unicode' }
        enable :dump_errors
        disable :raise_errors
        disable :show_exceptions # disable middleware displaying errors as html

        helpers Helpers
        register Sinatra::ActiveRecordExtension

        error ValidationFailed do
          halt env['sinatra.error'].status_code, env['sinatra.error'].message
        end

        error APIError do #MalformedJSON, AlreadyConfirmed, InvalidAuthorization, UserNotConfirmed, NotFound do
          env['warden'].custom_failure!
          halt env['sinatra.error'].status_code, { message: env['sinatra.error'].message }.to_json
        end

        not_found do
          { message: env['sinatra.error'].message }.to_json
        end

        error do
          Raven.capture_exception env['sinatra.error']
          halt 500, JSON.generate(message: 'Whoops, an error occured in duse')
        end
      end
    end
  end
end

