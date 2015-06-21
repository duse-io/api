module Duse
  module API
    module V1
      module Actions
        module User
          class GetMyself < Actions::Base
            authenticate
            status 200
            render JSONViews::User, type: :full

            def call
              current_user
            end
          end
        end
      end
    end
  end
end
