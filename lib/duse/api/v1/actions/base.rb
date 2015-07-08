module Duse
  module API
    module V1
      module Actions
        class Base
          attr_reader :current_user, :params, :json

          def initialize(current_user, params, json)
            @current_user = current_user
            @params = params
            @json = json
          end

          def run(args)
            result = call(*args)
            audit_log(action: self.class, args: args, result: 'success')
            result
          rescue => e
            audit_log(action: self.class, args: args, result: 'failed', error: e)
            raise e
          end

          def audit_logger
            @audit_logger ||= Logger.new(ENV['RACK_ENV'] == 'test' ? StringIO.new : STDOUT)
          end

          def audit_log(options)
            msg = "log_type=AUDIT_LOG timestamp=#{Time.now.strftime('%FT%T%:z')} user_id=#{user_id(current_user)} action=#{options[:action]} args=#{options[:action].arg_value_list(options[:args])} result=#{options[:result]}"
            msg = "#{msg} error=#{options[:error].class}" if options.key?(:result) == 'failed'
            audit_logger << "#{msg}\n"
          end

          def user_id(current_user)
            return '<Unauthenticated>' if current_user.nil?
            current_user.id
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
                _, name, *_ = parameter
                [name, args[index]]
              end.to_h.to_json
            end
          end
        end
      end
    end
  end
end
