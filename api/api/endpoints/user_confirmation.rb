require 'api/endpoints/base'
require 'api/facades/user'

module Duse
  module Endpoints
    class UserConfirmation < Base

      error Duse::AlreadyConfirmed do
        halt 400, { message: 'Account already confirmed' }.to_json
      end

      namespace '/v1' do
        namespace '/users' do
          post '/confirm' do
            email = JSON.parse(request_body)['email']
            UserFacade.new.resend_confirmation! email
            status 201
          end

          patch '/confirm' do
            confirmation_token = JSON.parse(request_body)['token']
            UserFacade.new.confirm! confirmation_token
            status 204
          end
        end
      end
    end
  end
end

