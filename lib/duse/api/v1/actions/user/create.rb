require 'duse/api/emails/confirmation_email'

module Duse
  module API
    module V1
      module Actions
        module User
          class Create < Actions::Base
            status 201
            validate_with JSONSchemas::User
            render JSONViews::User, type: :full

            def call
              user = Models::User.new sanitized_json
              fail ValidationFailed, { message: user.errors.full_messages }.to_json if !user.valid?
              user.save
              ConfirmationEmail.new(user).send
              user
            end
          end
        end
      end
    end
  end
end
