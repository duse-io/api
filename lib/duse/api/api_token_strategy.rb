require "warden"
require "duse/api/models/token"

module Duse
  module API
    class APITokenStrategy < ::Warden::Strategies::Base
      def valid?
        !api_token.blank?
      end

      def authenticate!
        token = Models::ApiToken.find_by_raw_token api_token
        if token.nil? || !token.user.confirmed?
          return fail! "Unauthenticated"
        end
        if token.still_valid?
          token.use!
          success! token.user
        end
      end

      private

      def api_token
        request.env["HTTP_AUTHORIZATION"]
      end
    end
  end
end

Warden::Strategies.add(:api_token, Duse::API::APITokenStrategy)

