module Duse
  class APITokenStrategy < ::Warden::Strategies::Base
    def valid?
      !api_token.blank?
    end

    def authenticate!
      user = Duse::Models::User.find_by_api_token api_token
      if user.nil?
        fail! 'Unauthenticated'
      else
        success! user
      end
    end

    private

    def api_token
      request.env['HTTP_AUTHORIZATION']
    end
  end
end

Warden::Strategies.add(:api_token, Duse::APITokenStrategy)

