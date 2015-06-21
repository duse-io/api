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
            alias_method :auth?, :auth

            def render(view = nil, view_opts = {})
              @view = view
              @view_opts = view_opts
            end

            def validate_with(schema)
              @schema = schema
            end

            def status(status_code)
              @status_code = status_code
            end

            def authenticate(auth_opts = { with: :api_token })
              @auth = true
              @auth_opts = auth_opts
            end
          end
        end
      end
    end
  end
end
