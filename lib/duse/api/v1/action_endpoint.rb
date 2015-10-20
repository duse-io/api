require "oj"
require "stringio"
require "rack"

module Duse
  module API
    module V1
      class ActionEndpoint
        attr_reader :action, :env
        private :action, :env

        def initialize(action, env)
          @action = action
          @env = env
        end

        def call(*args)
          authenticate!(action.auth_opts[:with]) if action.auth?
          result = action.new(env, current_user, params, json(action.schema)).run(args)
          [action.status_code, {}, render(result, action.view, action.view_opts)]
        end

        private

        def current_user
          env["warden"].user
        end

        def authenticate!(scope = :api_token)
          env["warden"].authenticate!(scope)
        end

        def params
          request.params
        end

        def request
          Rack::Request.new(env)
        end

        def request_json
          content = request.body
          content ||= "{}"
          begin
            Oj.strict_load(content, :symbol_keys => true)
          rescue Oj::ParseError
            raise MalformedJSON
          end
        end

        def json(schema)
          schema.new(request_json) if !schema.nil?
        end

        def render(result, view, view_opts)
          return nil if view.nil?
          Oj.dump(
            view.new(
              result,
              { current_user: current_user, host: request.host }.merge(view_opts)
            ).render,
            mode: :compat
          )
        end
      end
    end
  end
end

