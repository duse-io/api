require "duse/api/audit_logger"

module Duse
  module API
    module V1
      module Actions
        class Base
          attr_reader :env, :current_user, :params, :json

          def initialize(env, current_user, params, json)
            @env = env
            @current_user = current_user
            @params = params
            @json = json
          end

          def run(args)
            result = call(*args)
            audit_log(args: args, result: "success")
            result
          rescue => e
            audit_log(args: args, result: "failed", error: e)
            raise e
          end

          def audit_logger
            @audit_logger ||= AuditLogger.new(env["rack.errors"])
          end

          def audit_log(options)
            audit_logger.log(options.merge(action: self.class, current_user: current_user))
          end

          def action_name
            self.class.name.split("::").last.downcase.to_sym
          end

          def sanitized_json(options = {})
            self.json.sanitize({current_user: current_user, action: action_name}.merge(options))
          end

          class << self
            attr_reader :view, :view_opts, :schema, :status_code, :auth, :auth_opts

            def auth?
              !!auth
            end

            def render(view = nil, view_opts = {})
              set :view, view
              set :view_opts, view_opts
            end

            def validate_with(schema)
              set :schema, schema
            end

            def status(status_code)
              set :status_code, status_code
            end

            def authenticate(auth_opts = { with: :api_token })
              set :auth, true
              set :auth_opts, auth_opts
            end

            def set(option, value)
              define_singleton_method(option) { value }
            end

            def arg_value_list(args)
              parameters = self.instance_method(:call).parameters
              parameters.map.with_index do |parameter, index|
                [parameter[1], args[index]]
              end.to_h.to_json
            end
          end
        end
      end
    end
  end
end
