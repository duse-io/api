module Duse
  module API
    module Mediators
      class Base
        def initialize(options)
          @options = options
        end

        def self.run(options={})
          new(options).call
        end
      end
    end
  end
end
