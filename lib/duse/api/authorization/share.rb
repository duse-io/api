require "duse/api/authorization/base"

module Duse
  module API
    module Authorization
      class Share < Authorization::Base
        allow :read do |user, share|
          share.user.id == user.id
        end

        allow :update do |user, share|
          share.user.id == user.id
        end

        allow :delete do |user, share|
          share.user.id == user.id
        end
      end
    end
  end
end

