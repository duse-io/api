module Duse
  module API
    module V1
      module Mediators
        module User
          class ResetPassword < Mediators::Base
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
