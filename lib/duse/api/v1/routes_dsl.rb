require 'pathname'

module Duse
  module API
    module V1
      module RoutesDSL
        class Namespace
          include RoutesDSL

          def initialize(parent, name)
            @parent = parent
            @name = name
          end

          def route
            File.join(@parent.route, @name.to_s)
          end

          def add_endpoint(http_endpoint)
            endpoints << http_endpoint
          end
        end

        class HTTPEndpoint
          attr_reader :http_method, :status_code, :relative_route, :klass, :schema, :schema_opts, :view, :view_opts, :auth, :auth_opts

          def initialize(parent, http_method, status_code, relative_route, klass)
            @parent = parent
            @http_method = http_method.upcase
            @status_code = status_code
            @relative_route = relative_route
            @klass = klass
            @auth = false
          end

          def authenticate(opts = {})
            @auth = true
            @auth_opts = { with: :api_token }.merge(opts)
            self
          end

          def validate_with(schema, opts = {})
            @schema_opts = opts
            @schema = schema
            self
          end

          def render_with(view, opts = {})
            @view_opts = opts
            @view = view
            self
          end

          def absolute_route
            Pathname.new(File.join(@parent.route, relative_route)).cleanpath.to_s
          end

          def add_to_sinatra(sinatra_class)
            sinatra_class.instance_exec(http_method, status_code, absolute_route, klass, schema, view, view_opts, auth, auth_opts) do |http_method, status_code, absolute_route, klass, schema, view, view_opts, auth, auth_opts|
              send(http_method.downcase, absolute_route) do
                begin
                  authenticate!(auth_opts[:with]) if auth
                  status status_code
                  json = nil
                  json = schema.new(request_json) if !schema.nil?
                  result = klass.new(current_user, params, json).call
                  if view.nil?
                    nil
                  else
                    view.new(result, { current_user: current_user, host: request.host }.merge(view_opts)).render.to_json
                  end
                rescue => e
                  raise e
                end
              end
            end
          end
        end

        def namespace(name, &block)
          n = Namespace.new(self, name)
          n.instance_eval(&block)
          n.endpoints.each do |e|
            add_endpoint e
          end
        end

        %w(get post patch put delete).each do |http_method|
          define_method http_method do |*args|
            HTTPEndpoint.new(self, http_method, *args)
          end
        end

        def update(*args)
          patch(*args)
          put(*args)
        end

        def route
          '/'
        end

        def add_endpoint(http_endpoint)
          endpoints << http_endpoint
          http_endpoint.add_to_sinatra(sinatra_class)
        end

        def endpoints
          @endpoints ||= []
        end

        def sinatra_class
          @sinatra_class ||= Class.new(Base)
        end

        def call(env)
          @sinatra_instance ||= @sinatra_class.new
          @sinatra_instance.call(env)
        end
      end
    end
  end
end

