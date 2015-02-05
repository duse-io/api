require 'duse'

module Duse
  class APITokenStrategy < ::Warden::Strategies::Base
    def valid?
      !api_token.blank?
    end

    def authenticate!
      hash = Encryption.hmac(Duse.secret_key, api_token)
      token = Duse::Models::Token.find_by_token_hash hash
      if token.nil?
        return fail! 'Unauthenticated'
      end
      if token.still_valid?
        token.use!
        success! token.user
      end
    end

    private

    def api_token
      request.env['HTTP_AUTHORIZATION']
    end
  end
end

Warden::Strategies.add(:api_token, Duse::APITokenStrategy)

