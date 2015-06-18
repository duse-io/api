module Duse
  module API
    module V1
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
          content = request_body
          content ||= '{}'
          begin
            JSON.parse content, symbolize_names: true
          rescue JSON::ParserError
            raise MalformedJSON
          end
        end
      end
    end
  end
end

