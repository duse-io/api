module Duse
  module JSONViews
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
