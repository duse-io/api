module API
  class Secrets < Grape::API
    resource :secrets do
      get do
        Secret.all
      end

      post do
        secret = Secret.create!(extract_params [:title, :required, :split])
        extract_param(:parts).each_with_index do |part, index|
          secret_part = SecretPart.create!({index: index, secret: secret})
          part.each do |key, value|
            begin
              user = User.get!(key)
            rescue DataMapper::ObjectNotFoundError
              render_api_error! 'One of the provided users does not exist', 422
            end
            Share.create!({user: user, secret_part: secret_part, content: value})
          end
        end
      end
    end
  end
end
