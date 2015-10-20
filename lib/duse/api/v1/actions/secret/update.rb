require "duse/api/v1/json_schemas/secret"
require "duse/api/v1/json_views/secret"
require "duse/api/authorization/secret"

module Duse
  module API
    module V1
      module Actions
        module Secret
          class Update < Actions::Authenticated
            status 200
            validate_with JSONSchemas::Secret
            render JSONViews::Secret

            def call(secret_id)
              json = sanitized_json(strict: false)
              secret = Get.new(env, current_user, params, json).call(secret_id)
              Authorization::Secret.authorize! current_user, :update, secret
              if !json[:shares].nil?
                user_ids = []
                json[:shares].each do |s| 
                  s[:last_edited_by] = current_user
                  user_ids << s[:user_id]
                end
                json[:shares_attributes] = json.delete(:shares) # ActiveRecords makes us do this :(
                secret.shares.delete_all
                secret.user_ids = user_ids
              end
              if json.key?(:title) || json.key?(:cipher_text)
                secret.last_edited_by = current_user
              end
              if !json[:folder_id].nil?
                secret.user_secrets.where(user_id: current_user.id).first.update_attributes(
                  folder_id: json.delete(:folder_id)
                )
              end

              secret.assign_attributes json
              if !secret.save
                fail ValidationFailed, {message: secret.errors.full_messages}.to_json
              end
              secret
            end
          end
        end
      end
    end
  end
end
