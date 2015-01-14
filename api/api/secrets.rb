module API
  class Secrets < Grape::API
    before { authenticate! }

    resource :secrets do
      get do
        secrets = Share.all(user: current_user).secret_part.secret
        present secrets, with: Entities::Secret
      end

      get '/:id' do
        secret = Secret.get!(params[:id])
        Duse::SecretAuthorization.authorize! current_user, :read, secret
        present secret, with: Entities::Secret, type: :full, user: current_user
      end

      delete '/:id' do
        secret = Secret.get!(params[:id])
        Duse::SecretAuthorization.authorize! current_user, :read, secret
        secret.destroy
        status 204
      end

      patch '/:id' do
        secret = Secret.get!(params[:id])
        Duse::SecretAuthorization.authorize! current_user, :update, secret
        json = SecretJSON.new(params)
        json.validate!(strict: false, current_user: current_user)

        facade = SecretFacade.new
        begin
          secret = facade.update(params[:id], json.extract, current_user)
          present secret, with: Entities::Secret
        rescue DataMapper::SaveFailureError
          raise Duse::ValidationFailed, {message: facade.errors}.to_json
        end
      end

      post do
        json = SecretJSON.new(params)
        json.validate!(current_user: current_user)

        facade = SecretFacade.new
        begin
          secret = facade.create(json.extract, current_user)
          present secret, with: Entities::Secret
        rescue DataMapper::SaveFailureError
          raise Duse::ValidationFailed, {message: facade.errors}.to_json
        end
      end
    end
  end
end
