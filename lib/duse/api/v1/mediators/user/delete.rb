require 'duse/api/authorization/user'

module Duse
  module API
    module V1
      module Mediators
        module User
          class Delete < Mediators::Base
            def call
              user = Get.new(current_user, params, json).call
              Duse::API::UserAuthorization.authorize! current_user, :delete, user
              user.destroy
            end
          end
        end
      end
    end
  end
end
