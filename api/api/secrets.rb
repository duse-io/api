module API
  class Secrets < Grape::API
    before { authenticate! }

    resource :secrets do
      desc 'Retrieve all secrets the user has access to.'
      get do
        secrets = Share.all(user: current_user).secret_part.secret
        present secrets, with: Entities::Secret
      end

      desc 'Retrieve a secret with more detail than when retrieving all secrets'
      get '/:id' do
        present Secret.get!(params[:id]), with: Entities::Secret, type: :full
      end

      desc 'Delete a secret.'
      delete '/:id' do
        Secret.get!(params[:id]).destroy
        status 204
      end

      desc 'Retrieve the neccessary shares to reconstruct a secret.'
      get '/:id/shares' do
        secret = Secret.get!(params[:id])
        secret.secret_parts_for current_user
      end

      desc 'Create a new secret.'
      post do
        params[:last_edited_by] = current_user
        errors = SecretValidator.validate_json(params)
        entities = Secret.new_full(params)
        secret = entities[0]
        aggregate_secret_errors(errors, entities)
        render_api_error! errors.to_a, 422 unless errors.empty?
        entities.each(&:save)
        status 201
        present secret, with: Entities::Secret
      end
    end
  end
end
