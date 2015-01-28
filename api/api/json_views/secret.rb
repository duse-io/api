module Duse
  module JSONViews
    class Secret < Grape::Entity
      expose :id
      expose :title
      expose :parts, if: { type: :full } do |secret, options|
        secret.secret_parts_for options[:user]
      end
      expose :users, using: 'Duse::JSONViews::User', if: { type: :full }
      expose :url do |secret, opts|
        secret_url secret, opts
      end

      private

      def secret_url(secret, opts)
        "http://#{opts[:env]['HTTP_HOST']}/v1/secrets/#{secret.id}"
      end
    end
  end
end

