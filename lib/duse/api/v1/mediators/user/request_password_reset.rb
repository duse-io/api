require 'duse/api/emails/forgot_password_email'

module Duse
  module API
    module V1
      module Mediators
        module User
          class RequestPasswordReset < Mediators::Base
            def call
              user = Models::User.find_by_email json[:email]
              fail NotFound if user.nil?
              Models::ForgotPasswordToken.delete_all(user: user)
              ForgotPasswordEmail.new(user).send
            end
          end
        end
      end
    end
  end
end
