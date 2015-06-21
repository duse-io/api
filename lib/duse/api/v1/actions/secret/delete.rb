module Duse
  module API
    module V1
      module Actions
        module Secret
          class Delete < Actions::Base
            authenticate
            status 204

            def call
              secret = Get.new(current_user, params, json).call
              SecretAuthorization.authorize! current_user, :delete, secret
              secret.destroy
            end
          end
        end
      end
    end
  end
end
