require 'duse/api/authorization/base'

module Duse
  module API
    module Authorization
      class Secret < Authorization::Base
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
  end
end

