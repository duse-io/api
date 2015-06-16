module Duse
  module API
    module V1
      module Mediators
        module Secret
          class Update < Mediators::Base
            def call
              json = json.sanitize strict: false, current_user: current_user
              secret = Get.new(current_user, params, json).call
              Duse::API::SecretAuthorization.authorize! current_user, :update, secret
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

              if !secret.update(json)
                fail Duse::API::ValidationFailed, {message: secret.errors.full_messages}.to_json
              end
              secret
            end
          end
        end
      end
    end
  end
end
