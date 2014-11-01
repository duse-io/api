module API
  class Secrets < Grape::API
    resource :secrets do
      get do
        Secret.all
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
        parts.each_with_index do |part, index|
          secret_part = SecretPart.new({index: index, secret: secret})
          unless secret_part.valid?
            errors += secret_part.errors.full_messages
          end
          unless keys - part.keys
            errors << 'Users referenced in secret parts do not match in all parts'
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
          end
        end

        unless errors.empty?
          render_api_error! errors.uniq, 422
        end
      end
    end
  end
end
