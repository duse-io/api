require 'duse/authorization'

module Duse
  class SecretAuthorization < Authorization
    allow :read do |user, secret|
      user.has_access_to_secret?(secret)
    end

    allow :update do |user, secret|
      user.has_access_to_secret?(secret)
    end

    allow :delete do |user, secret|
      user.has_access_to_secret?(secret)
    end
  end
end

