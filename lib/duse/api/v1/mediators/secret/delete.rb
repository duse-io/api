module Duse
  module API
    module V1
      module Mediators
        module Secret
          class Delete < Mediators::Base
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
