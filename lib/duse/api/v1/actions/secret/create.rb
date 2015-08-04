module Duse
  module API
    module V1
      module Actions
        module Secret
          class Create < Actions::Authenticated
            status 201
            validate_with JSONSchemas::Secret
            render JSONViews::Secret

            def call
              fail ValidationFailed, {message: ['Your limit of secrets has been reached']}.to_json if @current_user.secrets.length >= @current_user.secret_limit
              params = sanitized_json
              user_ids = []
              params[:shares].each do |s| 
                s[:last_edited_by] = @current_user
                user_ids << s[:user_id]
              end
              secret = Models::Secret.new(
                title: params[:title],
                cipher_text: params[:cipher_text],
                last_edited_by: @current_user,
                shares_attributes: params[:shares],
                user_ids: user_ids
              )
              secret.user_secrets.each do |user_secret|
                user_secret.folder_id = params[:folder_id] if user_secret.user_id == current_user.id
              end

              if !secret.save
                raise ValidationFailed, {message: errors.errors.full_messages}.to_json
              end
              secret
            end
          end
        end
      end
    end
  end
end
