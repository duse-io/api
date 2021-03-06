require "pathname"

require "duse/api/v1/action_endpoint"
require "duse/api/v1/base"

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
          attr_reader :http_method, :relative_route, :action

          def initialize(parent, http_method, relative_route, action)
            @parent = parent
            @http_method = http_method
            @relative_route = relative_route
            @action = action
          end

          def absolute_route
            Pathname.new(File.join(@parent.route, relative_route)).cleanpath.to_s
          end

          def add_to_sinatra(sinatra_class)
            sinatra_class.instance_exec(http_method, absolute_route, action) do |http_method, absolute_route, action|
              send(http_method, absolute_route) do |*args|
                ActionEndpoint.new(action, env).call(*args)
              end
            end
          end
        end

        def namespace(name, &block)
          n = Namespace.new(self, name)
          n.instance_eval(&block)
          n.endpoints.each do |endpoint|
            add_endpoint endpoint
          end
        end

        %w(get post patch put delete).each do |http_method|
          define_method http_method do |relative_route_action|
            relative_route_action.each do |relative_route, action|
              add_endpoint HTTPEndpoint.new(self, http_method, relative_route, action)
            end
          end
        end

        def update(*args)
          patch(*args)
          put(*args)
        end

        def crud(action_group)
          get    "/"    => action_group.const_get(:List)
          post   "/"    => action_group.const_get(:Create)
          get    "/:id" => action_group.const_get(:Get)
          update "/:id" => action_group.const_get(:Update)
          delete "/:id" => action_group.const_get(:Delete)
        end

        def route
          "/"
        end

        def add_endpoint(http_endpoint)
          endpoints << http_endpoint
          http_endpoint.add_to_sinatra(sinatra_class)
        end

        def endpoints
          @endpoints ||= []
        end

        def sinatra_class
          @sinatra_class ||= Class.new(V1::Base)
        end

        def call(env)
          @sinatra_instance ||= sinatra_class.new
          @sinatra_instance.call(env)
        end
      end
    end
  end
end

