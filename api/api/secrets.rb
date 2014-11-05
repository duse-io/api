module API
  class Secrets < Grape::API
    before { authenticate! }

    resource :secrets do
      get do
        Share.all(user: current_user).secret_part.secret
      end

      delete '/:id' do
        Secret.get!(params[:id]).destroy
        status 204
      end

      get '/:id/users' do
        Secret.get!(params[:id]).secret_parts.shares.user
      end

      get '/:id/shares' do
        secret = Secret.get!(params[:id])
        secret.secret_parts(order: [:index.asc]).map do |part|
          part.shares(user: [User.first(username: 'server'), current_user]).map do |share|
            share.content
          end
        end
      end

      post do
        secret = Secret.new(extract_params [:title, :required, :split])

        errors = []

        unless secret.valid?
          errors += secret.errors.full_messages
        end

        parts = extract_param(:parts)

        unless parts.is_a? Array
          errors << 'Secret parts must be an array'
        end
        if parts.length < extract_param(:required)
          errors << 'Amount of secret parts is smaller than required to decrypt'
        end

        keys = parts.first.keys
        secret_parts = []
        shares = []
        parts.each_with_index do |part, index|
          secret_part = SecretPart.new({index: index, secret: secret})
          unless secret_part.valid?
            errors += secret_part.errors.full_messages
          end
          unless keys - part.keys
            errors << 'Users referenced in secret parts do not match in all parts'
          end
          unless part.has_key? User.first(username: 'server').id.to_s
            errors << 'Shares for the server must be present'
          end
          part.each do |key, value|
            begin
              user = User.get!(key)
            rescue DataMapper::ObjectNotFoundError
              errors << 'One or more of the provided users do not exist'
            end
            share = Share.new({user: user, secret_part: secret_part, content: value})
            unless share.valid?
              errors += share.errors.full_messages
            end
            shares << share
          end
          secret_parts << secret_part
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
