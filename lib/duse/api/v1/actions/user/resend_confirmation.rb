module Duse
  module API
    module V1
      module Actions
        module User
          class ResendConfirmation < Actions::Base
            def call
              user = Models::User.find_by_email json[:email]
              fail NotFound if user.nil?
              fail AlreadyConfirmed if user.confirmed?
              Models::ConfirmationToken.delete_all(user: user)
              ConfirmationEmail.new(user).send
            end
          end
        end
      end
    end
  end
end
