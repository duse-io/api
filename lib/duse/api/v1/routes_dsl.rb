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
          attr_reader :http_method, :status_code, :json_schema, :json_view, :relative_route, :klass, :options

          def initialize(parent, http_method, status_code, json_schema, json_view, relative_route, klass, options = {})
            @parent = parent
            @http_method = http_method.upcase
            @status_code = status_code
            @json_schema = json_schema
            @json_view = json_view
            @relative_route = relative_route
            @klass = klass
            @options = { auth: :api_token }.merge(options)
          end

          def absolute_route
            Pathname.new(File.join(@parent.route, relative_route)).cleanpath.to_s
          end

          def add_to_sinatra(sinatra_class)
            sinatra_class.send(http_method) do
              authenticate! options[:auth]
              status status_code
              json = nil
              json = json_schema.new(request_json) if json_schema.nil?
              result = @klass.new(current_user, params, json).call
              if json_view.nil?
                nil
              else
                json_view.new(result, current_user: current_user).render 
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
          define_method http_method do |status_code, json_schema, json_view, relative_route, klass|
            e = HTTPEndpoint.new(
              self, 
              http_method,
              status_code,
              json_schema,
              json_view,
              relative_route,
              klass
            )
            add_endpoint e
            e.add_to_sinatra(self)
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
          
        end

        def endpoints
          @endpoints ||= []
        end
      end
    end
  end
end

