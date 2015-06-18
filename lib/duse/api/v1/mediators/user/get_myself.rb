module Duse
  module API
    module V1
      module Mediators
        module User
          class GetMyself < Mediators::Base
            def call
              current_user
            end
          end
        end
      end
    end
  end
end
