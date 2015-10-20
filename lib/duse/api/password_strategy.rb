require "warden"
require "duse/api/models/user"

module Duse
  module API
    class PasswordStrategy < ::Warden::Strategies::Base
      def valid?
        username && password
      end

      def authenticate!
        user = Models::User.find_by_username username
        if !user.nil? && user.try(:authenticate, password)
          return success! user
        end
        fail! "Username or password incorrect."
      end

      def username
        post_params["username"]
      end

      def password
        post_params["password"]
      end

      def post_params
        json = request.body.gets
        request.body.rewind
        JSON.parse(json)
      end
    end
  end
end

Warden::Strategies.add(:password, Duse::API::PasswordStrategy)

