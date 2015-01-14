module API
  class Secrets < Grape::API
    before { authenticate! }

    helpers do
      def facade
        SecretFacade.new(current_user)
      end
    end

    resource :secrets do
      get do
        present facade.all, with: Entities::Secret
      end

      get '/:id' do
        secret = facade.get!(params[:id])
        present secret, with: Entities::Secret, type: :full, user: current_user
      end

      delete '/:id' do
        facade.delete! params[:id]
        status 204
      end

      patch '/:id' do
        secret = facade.update!(params[:id], SecretJSON.new(params))
        present secret, with: Entities::Secret
      end

      post do
        secret = facade.create!(SecretJSON.new(params))
        present secret, with: Entities::Secret
      end
    end
  end
end
