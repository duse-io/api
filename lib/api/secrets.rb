module API
  class Secrets < Grape::API
    resource :secrets do
      get do
        Secret.all
      end

      post do
        required_attributes! [:title, :required, :split, :parts]

        attrs = attributes_for_keys [:title, :required, :split, :parts]
        secret = Secret.create attrs
        attrs.parts.each_with_index do |part, index|
          secret_part = SecretPart.create({index: index, secret: secret})
          part.each do |key, value|
            user = User.get(key)
            Share.create({user: user, secret_part: secret_part, content: value})
          end
        end
      end
    end
  end
end
