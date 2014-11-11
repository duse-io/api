module API
  module Entities
    class Secret < Grape::Entity
      expose :id, documentation: { type: 'integer', desc: 'Id of the secret.' }
      expose :title, documentation: { type: 'string', desc: 'Title for the secret.' }
      expose :required, documentation: { type: 'integer', desc: 'Number of shares required to reconstruct this secret.' }
      expose :split, documentation: { type: 'integer', desc: 'Number of chars the secret was split into before applying Shamir\'s Secret Sharing' }
      expose :users, using: "API::Entities::User", if: { type: :full }
      expose :url do |secret, opts|
        secret_url secret, opts
      end
      expose :users_url do |secret, opts|
        users_url secret, opts
      end
      expose :shares_url do |secret, opts|
        shares_url secret, opts
      end

      private

      def secret_url(secret, opts)
        "http://#{opts[:env]['HTTP_HOST']}/v1/secrets/#{secret.id}"
      end

      def users_url(secret, opts)
        secret_url(secret, opts) + '/users'
      end

      def shares_url(secret, opts)
        secret_url(secret, opts) + '/shares'
      end
    end

    class User < Grape::Entity
      expose :id, documentation: { type: 'integer', desc: 'The users id.' }
      expose :username, documentation: { type: 'string', desc: 'The users username' }
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
