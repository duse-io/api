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
