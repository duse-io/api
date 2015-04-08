require 'duse/api/authorization'

module Duse
  module API
    class UserAuthorization < Authorization
      allow :delete do |current_user, user|
        current_user.id == user.id
      end

      allow :update do |current_user, user|
        current_user.id == user.id
      end
    end
  end
end

