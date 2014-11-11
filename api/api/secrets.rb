module API
  class Secrets < Grape::API
    before { authenticate! }

    resource :secrets do
      desc 'Retrieve all secrets the user has access to.'
      get do
        secrets = Model::Share.all(user: current_user).secret_part.secret
        present secrets, with: Entities::Secret
      end

      desc 'Delete a secret.'
      delete '/:id' do
        Model::Secret.get!(params[:id]).destroy
        status 204
      end

      desc 'Retrieve all users that have access to a secret.'
      get '/:id/users' do
        present Model::Secret.get!(params[:id]).users, with: Entities::User
      end

      desc 'Retrieve the neccessary shares to reconstruct a secret.'
      get '/:id/shares' do
        secret = Model::Secret.get!(params[:id])
        secret.secret_parts_for [current_user]
      end

      desc 'Create a new secret.'
      post do
        errors = SecretValidator.validate_json(params)
        entities = Model::Secret.new_full(params)
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
