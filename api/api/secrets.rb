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
        params[:last_edited_by] = current_user
        errors = SecretJSON.validate(params)
        if errors.empty?
          errors.merge SecretValidator.validate(params)
        end
        if errors.empty?
          entities = Secret.new_full(params, current_user)
          secret = entities[0]
          aggregate_secret_errors(errors, entities)
        end
        render_api_error! errors.to_a, 422 unless errors.empty?
        entities.each(&:save)
        present secret, with: Entities::Secret
      end
    end
  end
end
