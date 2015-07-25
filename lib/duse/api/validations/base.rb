module Duse
  module API
    module Validations
      class Base
        attr_reader :options

        def initialize(options = {})
          @options = options
        end
      end
    end
  end
end

