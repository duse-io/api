module API
  module Entities
    class Secret < Grape::Entity
      expose :id, documentation: { type: 'integer' }
      expose :title, documentation: { type: 'string' }
      expose :required, documentation: { type: 'integer' }
      expose :users, using: 'API::Entities::User', if: { type: :full }
      expose :url do |secret, opts|
        secret_url secret, opts
      end
      expose :shares_url do |secret, opts|
        shares_url secret, opts
      end

      private

      def secret_url(secret, opts)
        "http://#{opts[:env]['HTTP_HOST']}/v1/secrets/#{secret.id}"
      end

      def shares_url(secret, opts)
        secret_url(secret, opts) + '/shares'
      end
    end

    class User < Grape::Entity
      expose :id, documentation: { type: 'integer' }
      expose :username, documentation: { type: 'string' }
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
