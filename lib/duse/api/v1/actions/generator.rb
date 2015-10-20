require "duse/api/v1/actions/authenticated"

module Duse
  module API
    module V1
      module Actions
        class Generator
          attr_reader :base, :status, :namespace, :model_name, :model, :view, :authorization

          def initialize(status, namespace)
            @base = Actions::Authenticated
            @status = status
            @namespace = namespace
            @model_name = @namespace.name.split("::").last
          end

          def default_model
            @model = Models.const_get(model_name)
            self
          end

          def default_view
            @view = JSONViews.const_get(model_name)
            self
          end

          def default_authorization
            @authorization = Authorization.const_get(model_name)
            self
          end
        end

        class GetGenerator < Generator
          def initialize(namespace)
            super(200, namespace)
            default_model
            default_view
            default_authorization
          end

          def build
            action = Class.new(base)
            action.status status
            action.render view, type: :full
            action.instance_exec(namespace, model, authorization) do |namespace, model, authorization|
              define_method :call do |id|
                begin
                  entity = model.find id
                  authorization.authorize!(current_user, :read, entity) if !authorization.nil?
                  entity
                rescue ActiveRecord::RecordNotFound
                  raise NotFound
                end
              end
            end
            action
          end
        end

        class DeleteGenerator < Generator
          def initialize(namespace)
            super(204, namespace)
            default_model
            default_authorization
          end

          def build
            action = Class.new(base)
            action.status status
            action.instance_exec(namespace, model, authorization) do |namespace, model, authorization|
              define_method :call do |id|
                entity = namespace.const_get(:Get).new(env, current_user, params, json).call(id)
                authorization.authorize!(current_user, :delete, entity) if !authorization.nil?
                entity.destroy
              end
            end
            action
          end
        end
      end
    end
  end
end

