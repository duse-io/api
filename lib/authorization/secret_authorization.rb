require 'models/user'
require 'models/secret'
require 'models/secret_part'
require 'models/share'

module Duse
  class InvalidAuthorization < StandardError; end

  class Authorization
    def self.allow(action, &block)
      @abilities ||= {}
      @abilities[action] = ->(user, secret) { true }
      @abilities[action] = block unless block.nil?
    end

    def self.authorize!(user, action, object)
      block  = @abilities[action]
      result = block.call(user, object)
      fail InvalidAuthorization unless result
    end
  end

  class SecretAuthorization < Authorization
    allow :read do |user, secret|
      Share.all(user: user).secret_part.secret.get(secret.id)
    end
  end
end
