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
          attr_reader :http_method, :relative_route, :klass

          def initialize(parent, http_method, relative_route, klass)
            @parent = parent
            @http_method = http_method.upcase
            @relative_route = relative_route
            @klass = klass
          end

          def absolute_route
            Pathname.new(File.join(@parent.route, relative_route)).cleanpath.to_s
          end

          def add_to_sinatra(sinatra_class)
            sinatra_class.send(http_method) do
              @klass.new(current_user, json).call
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

