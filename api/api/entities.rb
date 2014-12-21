module API
  module Entities
    class Secret < Grape::Entity
      expose :id
      expose :title
      expose :required
      expose :shares, if: { type: :full } do |secret, options|
        secret.secret_parts_for options[:user]
      end
      expose :users, using: 'API::Entities::User', if: { type: :full }
      expose :url do |secret, opts|
        secret_url secret, opts
      end

      private

      def secret_url(secret, opts)
        "http://#{opts[:env]['HTTP_HOST']}/v1/secrets/#{secret.id}"
      end
    end

    class User < Grape::Entity
      expose :id
      expose :username
      expose :public_key, if: { type: :full } do |user, _|
        user.public_key.to_s
      end
      expose :url do |user, opts|
        user_url user, opts
      end

      private

      def user_url(user, opts)
        "http://#{opts[:env]['HTTP_HOST']}/v1/users/#{user.id}"
      end
    end
  end
end
