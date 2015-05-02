require 'duse/api/json_view'
require 'duse/api/v1/json_views/user'

module Duse
  module JSONViews
    class Secret < JSONView
      property :id
      property :title
      property :cipher_text, type: :full
      property :shares, type: :full do |secret, options|
        secret.shares_for options[:user]
      end
      property :users, as: Duse::JSONViews::User, type: :full
      property :url do |secret, options|
        "http://#{options[:host]}/v1/secrets/#{secret.id}"
      end
    end
  end
end

