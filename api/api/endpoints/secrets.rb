require 'api/endpoints/base'
require 'api/facades/secret'
require 'api/json_views/secret'
require 'api/json/secret'

module Duse
  module Endpoints
    class Secrets < Base
      helpers do
        def facade
          SecretFacade.new(current_user)
        end

        def view(subject, options = {})
          JSONViews::Secret.new(subject, options.merge({host: request.host}))
        end
      end

      namespace '/v1' do
        namespace '/secrets' do
          before { authenticate! }

          get do
            json(view(facade.all).render)
          end

          get '/:id' do
            secret = facade.get!(params[:id])
            json(view(secret, type: :full, user: current_user).render)
          end

          delete '/:id' do
            facade.delete! params[:id]
            status 204
          end

          patch '/:id' do
            secret = facade.update!(params[:id], SecretJSON.new(request_body))
            json(view(secret).render)
          end

          post do
            secret = facade.create!(SecretJSON.new(request_body))
            status 201
            json(view(secret).render)
          end
        end
      end
    end
  end
end

