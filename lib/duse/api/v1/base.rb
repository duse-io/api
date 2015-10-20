require "sinatra/base"
require "sinatra/activerecord"

require "duse/api/errors"

module Duse
  module API
    module V1
      class Base < Sinatra::Base
        set :database, ENV["DATABASE_URL"]
        set :database_extras, { pool: 5, timeout: 3000, encoding: "unicode" }
        disable :raise_errors, :show_exceptions, :dump_errors, :logging

        register Sinatra::ActiveRecordExtension

        error APIError do
          env["warden"].custom_failure!
          halt env["sinatra.error"].status_code, env["sinatra.error"].json
        end

        error do
          Raven.capture_exception env["sinatra.error"]
          if (ENV["RACK_ENV"] == "development") || (ENV["RACK_ENV"] == "test" && !ENV["CI"])
            puts env["sinatra.error"]
            puts env["sinatra.error"].backtrace
          end
          halt 500, JSON.generate(message: "Whoops, an error occured in duse")
        end
      end
    end
  end
end

