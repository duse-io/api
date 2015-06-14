module Duse
  module API
    module V1
      module Mediators
        module User
          class CreateAuthToken < Mediators::Base
            def call
              fail UserNotConfirmed unless current_user.confirmed?
              OpenStruct.new api_token: current_user.create_new_token
            end
          end
        end
      end
    end
  end
end
