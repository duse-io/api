module Duse
  module API
    module Validations
      module Base
        def initialize(options = {})
          @options = options
        end

        def options
          @options
        end
      end
    end
  end
end

