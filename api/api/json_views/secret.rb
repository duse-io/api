module Duse
  module JSONViews
    class Secret < JSONView
      property :id
      property :title
      property :parts, type: :full do |secret, options|
        secret.secret_parts_for options[:user]
      end
      property :users, as: Duse::JSONViews::User, type: :full
      property :url do |secret, options|
        "http://#{options[:host]}/v1/secrets/#{secret.id}"
      end
    end
  end
end

