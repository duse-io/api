module Duse
  module API
    module V1
      module Mediators
        module User
          class Confirm < Mediators::Base
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
