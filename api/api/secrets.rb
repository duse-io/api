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
        secret = Model::Secret.new(extract_params [:title, :required, :split])
        entities = [secret]

        params[:parts].each_with_index do |part, index|
          secret_part = Model::SecretPart.new({index: index, secret: secret})

          part.each do |user_id, share|
            user = Model::User.get(user_id)
            entities << Model::Share.new({user: user, secret_part: secret_part, content: share})
          end

          entities << secret_part
        end

        entities.each do |entity|
          errors += entity.errors.full_messages unless entity.valid?
        end
        errors -= ['Secret must not be blank', 'Secret part must not be blank']
        unless errors.empty?
          render_api_error! errors.uniq, 422
        end
        entities.each(&:save)
        status 201
      end
    end
  end
end
