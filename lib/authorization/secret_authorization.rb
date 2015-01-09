require 'models/user'
require 'models/secret'
require 'models/secret_part'
require 'models/share'

module Duse
  class InvalidAuthorization < StandardError; end

  class Authorization
    def self.allow(action, &block)
      @abilities ||= {}
      @abilities[action] = ->(_, _) { true }
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
      user.has_access_to_secret?(secret)
    end
  end
end
