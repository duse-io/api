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
          attr_reader :http_method, :status_code, :json_schema, :json_view, :relative_route, :klass, :opts

          def initialize(parent, http_method, status_code, json_schema, json_view, relative_route, klass, opts = {})
            @parent = parent
            @http_method = http_method.upcase
            @status_code = status_code
            @json_schema = json_schema
            @json_view = json_view
            @relative_route = relative_route
            @klass = klass
            @opts = { auth: :api_token }.merge(opts)
          end

          def absolute_route
            Pathname.new(File.join(@parent.route, relative_route)).cleanpath.to_s
          end

          def add_to_sinatra(sinatra_class)
            sinatra_class.instance_exec(http_method, klass, absolute_route, status_code, json_schema, json_view, opts) do |http_method, klass, absolute_route, status_code, json_schema, json_view, opts|
              send(http_method.downcase, absolute_route) do
                begin
                  authenticate!(opts[:auth]) if opts[:auth] != :none
                  status status_code
                  json = nil
                  json = json_schema.new(request_json) if !json_schema.nil?
                  result = klass.new(current_user, params, json).call
                  if json_view.nil?
                    nil
                  else
                    json_view.new(result, { current_user: current_user, host: request.host }.merge(opts)).render.to_json
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
          define_method http_method do |status_code, json_schema, json_view, relative_route, klass, options = {}|
            e = HTTPEndpoint.new(
              self, 
              http_method,
              status_code,
              json_schema,
              json_view,
              relative_route,
              klass,
              { auth: :api_token }.merge(options)
            )
            add_endpoint e
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

