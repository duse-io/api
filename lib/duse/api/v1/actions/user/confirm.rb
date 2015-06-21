module Duse
  module API
    module V1
      module Actions
        module User
          class Confirm < Actions::Base
            status 204
            validate_with JSONSchemas::Token

            def call
              token = Models::ConfirmationToken.find_by_raw_token json[:token]
              fail NotFound if token.nil?
              fail AlreadyConfirmed if token.user.confirmed?
              token.user.confirm!
              token.destroy
            end
          end
        end
      end
    end
  end
end
