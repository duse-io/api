module Duse
  module API
    module V1
      module Actions
        module User
          class GetMyself < Actions::Base
            def call
              current_user
            end
          end
        end
      end
    end
  end
end
