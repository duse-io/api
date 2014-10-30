module API
  class Secrets < Grape::API
    resource :secrets do
      get do
        Secret.all
      end

      post do
        secret = Secret.create({title: params.title, required: params.required, split: params.split})
        params.parts.each_with_index do |part, index|
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
