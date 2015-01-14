module API
  class Secrets < Grape::API
    before { authenticate! }

    resource :secrets do
      get do
        facade = SecretFacade.new(current_user)
        secrets = facade.all
        present secrets, with: Entities::Secret
      end

      get '/:id' do
        facade = SecretFacade.new(current_user)
        secret = facade.get!(params[:id])
        present secret, with: Entities::Secret, type: :full, user: current_user
      end

      delete '/:id' do
        facade = SecretFacade.new(current_user)
        facade.delete! params[:id]
        status 204
      end

      patch '/:id' do
        facade = SecretFacade.new(current_user)
        begin
          secret = facade.update!(params[:id], SecretJSON.new(params))
          present secret, with: Entities::Secret
        rescue DataMapper::SaveFailureError
          raise Duse::ValidationFailed, {message: facade.errors}.to_json
        end
      end

      post do
        facade = SecretFacade.new(current_user)
        begin
          secret = facade.create!(SecretJSON.new(params))
          present secret, with: Entities::Secret
        rescue DataMapper::SaveFailureError
          raise Duse::ValidationFailed, {message: facade.errors}.to_json
        end
      end
    end
  end
end
