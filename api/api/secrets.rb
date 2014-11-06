module API
  class Secrets < Grape::API
    before { authenticate! }

    resource :secrets do
      get do
        secrets = Model::Share.all(user: current_user).secret_part.secret
        present secrets, with: Entities::Secret
      end

      delete '/:id' do
        Model::Secret.get!(params[:id]).destroy
        status 204
      end

      get '/:id/users' do
        Model::Secret.get!(params[:id]).secret_parts.shares.user
      end

      get '/:id/shares' do
        secret = Model::Secret.get!(params[:id])
        secret.secret_parts(order: [:index.asc]).map do |part|
          part.shares(user: [Model::User.first(username: 'server'), current_user]).map do |share|
            share.content
          end
        end
      end

      post do
        errors = SecretValidator.validate_json(params)
        entities = Model::Secret.new_full(params)

        entities.each do |entity|
          errors = errors.merge entity.errors.full_messages unless entity.valid?
        end

        errors = errors.subtract ['Secret must not be blank', 'Secret part must not be blank']
        render_api_error! errors.to_a, 422 unless errors.empty?
        entities.each(&:save)
        status 201
      end
    end
  end
end
