require 'duse/errors'
require 'duse/authorization'
require 'api/endpoints/helpers'
require 'duse'

module Duse
  module Endpoints
    class Base < Sinatra::Base
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

      error Duse::InvalidAuthorization do
        halt 403, { message: 'You are not authorized to access a resource' }.to_json
      end

      error Duse::NotFound do
        halt 404, { message: 'Not found' }.to_json
      end

      error Duse::ValidationFailed do
        halt 422, env['sinatra.error'].message
      end

      error do
        Raven.capture_exception env['sinatra.error']
        halt 500, JSON.generate(message: 'Whoops, an error occured in duse')
      end
    end
  end
end

