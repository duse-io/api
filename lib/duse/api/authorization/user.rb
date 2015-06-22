require 'duse/api/authorization/base'

module Duse
  module API
    module Authorization
      class User < Authorization::Base
        allow :delete do |current_user, user|
          current_user.id == user.id
        end

        allow :update do |current_user, user|
          current_user.id == user.id
        end
      end
    end
  end
end

