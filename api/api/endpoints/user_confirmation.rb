require 'api/endpoints/base'
require 'api/actions/user_confirmation'

module Duse
  module Endpoints
    class UserConfirmation < Base

      error Duse::AlreadyConfirmed do
        halt 400, { message: 'Account already confirmed' }.to_json
      end

      namespace '/v1' do
        namespace '/users' do
          post '/confirm' do
            User::Confirmation.new.resend request_json
            status 201
          end

          patch '/confirm' do
            User::Confirmation.new.confirm request_json
            status 204
          end
        end
      end
    end
  end
end

