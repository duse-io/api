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
        present secret, with: Entities::Secret, type: :full
      end

      delete '/:id' do
        secret = Secret.get!(params[:id])
        Duse::SecretAuthorization.authorize! current_user, :read, secret
        secret.destroy
        status 204
      end

      get '/:id/shares' do
        secret = Secret.get!(params[:id])
        Duse::SecretAuthorization.authorize! current_user, :read, secret
        secret.secret_parts_for current_user
      end

      post do
        json = SecretJSON.new(params)
        render_api_error! json.errors, 422 unless json.valid?

        json = json.extract
        json[:last_edited_by] = current_user
        entities = Secret.new_full(json, current_user)
        secret = entities[0]
        errors = secret_errors(entities)
        render_api_error! errors.to_a, 422 unless errors.empty?
        entities.each(&:save)
        present secret, with: Entities::Secret
      end
    end
  end
end
