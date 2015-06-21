require 'duse/api/v1/actions/user/get'

module Duse
  module API
    module V1
      module Actions
        module User
          class GetMyself < User::Get
            def call
              current_user
            end
          end
        end
      end
    end
  end
end
