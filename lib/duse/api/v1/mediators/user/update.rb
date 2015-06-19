module Duse
  module API
    module V1
      module Mediators
        module User
          class Update < Mediators::Base
            def call
              user = Get.new(current_user, params, json).call
              UserAuthorization.authorize! current_user, :update, user
              current_password = json[:current_password]
              fail ValidationFailed, { message: 'Wrong current password' }.to_json if !user.try(:authenticate, current_password)
              sanitized_json = json.sanitize(strict: false)
              if !user.update(sanitized_json)
                fail ValidationFailed, { message: user.errors.full_messages }.to_json
              end
              user
            end
          end
        end
      end
    end
  end
end
