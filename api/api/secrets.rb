module API
  class Secrets < Grape::API
    before { authenticate! }

    resource :secrets do
      get do
        Model::Share.all(user: current_user).secret_part.secret
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
        secret = Model::Secret.new(extract_params [:title, :required, :split])

        errors = []
        errors += secret.errors.full_messages unless secret.valid?

        secret_parts = params[:parts]

        errors << 'Secret parts must be an array' unless secret_parts.is_a? Array
        errors << 'Amount of secret parts is smaller than required to decrypt' if secret_parts.length < params[:required]

        keys = secret_parts.first.keys
        shares = []
        secret_parts.map.with_index do |part, index|
          secret_part = Model::SecretPart.new({index: index, secret: secret})
          errors += secret_part.errors.full_messages unless secret_part.valid?
          errors << 'Users referenced in secret parts do not match in all parts' unless (keys - part.keys).empty?
          errors << 'Shares for the server must be present' unless part.has_key? Model::User.first(username: 'server').id.to_s

          part.each do |key, value|
            user = Model::User.get key
            errors << 'One or more of the provided users do not exist' if user.nil?
            share = Model::Share.new({user: user, secret_part: secret_part, content: value})
            errors += share.errors.full_messages unless share.valid?
            shares << share
          end

          secret_part
        end

        errors -= ['Secret must not be blank', 'Secret part must not be blank']
        unless errors.empty?
          render_api_error! errors.uniq, 422
        end
        secret.save
        secret_parts.each(&:save)
        shares.each(&:save)
        status 201
      end
    end
  end
end
