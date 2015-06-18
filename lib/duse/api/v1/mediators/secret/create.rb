module Duse
  module API
    module V1
      module Mediators
        module Secret
          class Create < Mediators::Base
            def call
              fail Duse::API::ValidationFailed, {message: ['Your limit of secrets has been reached']}.to_json if @current_user.secrets.length >= 10
              sanitized_json = json.sanitize current_user: @current_user
              user_ids = []
              sanitized_json[:shares].each do |s| 
                s[:last_edited_by] = @current_user
                user_ids << s[:user_id]
              end
              secret = Duse::Models::Secret.new(
                title: sanitized_json[:title],
                cipher_text: sanitized_json[:cipher_text],
                last_edited_by: @current_user,
                shares_attributes: sanitized_json[:shares],
                user_ids: user_ids
              )

              if !secret.save
                raise Duse::API::ValidationFailed, {message: errors.errors.full_messages}.to_json
              end
              secret
            end
          end
        end
      end
    end
  end
end
