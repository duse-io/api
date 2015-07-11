module Duse
  module API
    module V1
      module Actions
        module Folder
          class Update < Actions::Authenticated
            status 200
            validate_with JSONSchemas::Folder
            render JSONViews::Folder

            def call(secret_id)
              folder = Get.new(env, current_user, params, json).call(secret_id)
              Authorization::Folder.authorize! current_user, :update, folder
              json = self.json.sanitize(strict: false, user: current_user)
              if !folder.update(json)
                fail ValidationFailed, { message: folder.errors.full_messages }.to_json
              end
              folder
            end
          end
        end
      end
    end
  end
end
