require 'duse/api/authorization/user'

module Duse
  module API
    module V1
      module Actions
        module User
          class Delete < Actions::Authenticated
            status 204

            def call
              user = Get.new(current_user, params, json).call
              UserAuthorization.authorize! current_user, :delete, user
              user.destroy
            end
          end
        end
      end
    end
  end
end
