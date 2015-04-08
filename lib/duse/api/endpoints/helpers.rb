module Duse
  module API
    module Endpoints
      module Helpers
        def current_user
          env['warden'].user
        end

        def authenticate!(scope = :api_token)
          env['warden'].authenticate!(scope)
        end

        def request_body
          result = request.body.gets
          request.body.rewind
          result
        end

        def request_json
          JSON.parse request_body, symbolize_names: true
        end
      end
    end
  end
end

