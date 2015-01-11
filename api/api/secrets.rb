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
        render_api_error! json.errors, 422 unless json.valid?(strict: false)

        updater = SecretUpdater.new(params[:id])
        begin
          secret = updater.update(json.extract, current_user)
          present secret, with: Entities::Secret
        rescue DataMapper::SaveFailureError
          render_api_error! updater.errors, 422
        end
      end

      post do
        json = SecretJSON.new(params)
        render_api_error! json.errors, 422 unless json.valid?

        factory = SecretFactory.new
        begin
          secret = factory.create_from_json(json.extract, current_user)
          present secret, with: Entities::Secret
        rescue DataMapper::SaveFailureError
          render_api_error! factory.errors, 422
        end
      end
    end
  end
end
