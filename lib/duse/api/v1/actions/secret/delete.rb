module Duse
  module API
    module V1
      module Actions
        module Secret
          class Delete < Actions::Authenticated
            status 204

            def call(secret_id)
              secret = Get.new(current_user, params, json).call(secret_id)
              SecretAuthorization.authorize! current_user, :delete, secret
              secret.destroy
            end
          end
        end
      end
    end
  end
end
