module Duse
  module API
    module V1
      module Actions
        module User
          class ResetPassword < Actions::Base
            status 204
            validate_with JSONSchemas::Password

            def call
              token = Models::ForgotPasswordToken.find_by_raw_token json[:token]
              fail NotFound if token.nil?
              user = token.user
              token.destroy

              password = json.sanitize(strict: false)[:password]
              user.update(password: password)
            end
          end
        end
      end
    end
  end
end
