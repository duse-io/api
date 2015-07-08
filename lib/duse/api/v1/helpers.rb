require 'stringio'

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

        def json(schema)
          schema.new(request_json) if !schema.nil?
        end

        def render(result, view, view_opts)
          return nil if view.nil?
          view.new(
            result,
            { current_user: current_user, host: request.host }.merge(view_opts)
          ).render.to_json
        end
      end
    end
  end
end

