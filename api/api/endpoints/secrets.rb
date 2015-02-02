module Duse
  module Endpoints
    class Secrets < Grape::API
      before { authenticate! }

      helpers do
        def facade
          SecretFacade.new(current_user)
        end

        def view(subject, options = {})
          JSONViews::Secret.new(subject, options.merge({host: 'example.org'}))
        end
      end

      resource :secrets do
        get do
          view(facade.all).render
        end

        get '/:id' do
          secret = facade.get!(params[:id])
          view(secret, type: :full, user: current_user).render
        end

        delete '/:id' do
          facade.delete! params[:id]
          status 204
        end

        patch '/:id' do
          secret = facade.update!(params[:id], SecretJSON.new(params))
          view(secret).render
        end

        post do
          secret = facade.create!(SecretJSON.new(params))
          view(secret).render
        end
      end
    end
  end
end

