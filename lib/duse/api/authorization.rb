module Duse
  module API
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
  end
end

