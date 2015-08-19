module Duse
  module API
    module Authorization
      class Base
        def self.allow(action, &block)
          @abilities ||= {}
          @abilities[action] = ->(_, _) { true }
          @abilities[action] = block unless block.nil?
        end

        def self.authorize!(user, action, object)
          return if user.admin? # admin can do everything
          block  = @abilities[action]
          result = block.call(user, object)
          fail InvalidAuthorization unless result
        end
      end
    end
  end
end

