require 'duse/api/emails/confirmation_email'

module Duse
  module API
    module V1
      module Mediators
        module User
          class Create < Mediators::Base
            def call
              sanitized_json = json.sanitize
              user = Duse::Models::User.new sanitized_json
              fail Duse::API::ValidationFailed, { message: user.errors.full_messages }.to_json if !user.valid?
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
