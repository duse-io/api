module Duse
  module Endpoints
    class Secrets < Grape::API
      before { authenticate! }

      helpers do
        def facade
          SecretFacade.new(current_user)
        end
      end

      resource :secrets do
        get do
          present facade.all, with: Duse::JSONViews::Secret
        end

        get '/:id' do
          secret = facade.get!(params[:id])
          present secret, with: Duse::JSONViews::Secret, type: :full, user: current_user
        end

        delete '/:id' do
          facade.delete! params[:id]
          status 204
        end

        patch '/:id' do
          secret = facade.update!(params[:id], SecretJSON.new(params))
          present secret, with: Duse::JSONViews::Secret
        end

        post do
          secret = facade.create!(SecretJSON.new(params))
          present secret, with: Duse::JSONViews::Secret
        end
      end
    end
  end
end
