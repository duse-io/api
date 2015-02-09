require 'duse/json/json_view'

module Duse
  module JSONViews
    class User < JSONView
      property :id
      property :username
      property :email
      property :public_key, type: :full do |user, _|
        user.public_key.to_s
      end
      property :url do |user, options|
        "http://#{options[:host]}/v1/users/#{user.id}"
      end
    end
  end
end

