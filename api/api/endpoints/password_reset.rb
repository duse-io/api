require 'api/endpoints/base'
require 'api/actions/password_reset'

module Duse
  module Endpoints
    class PasswordReset < Base
      namespace '/v1' do
        namespace '/users' do
          post '/forgot_password' do
            email = JSON.parse(request_body)['email']
            User::PasswordReset.new.request_reset email
            status 201
          end

          patch '/password' do
            User::PasswordReset.new.reset(request_body)
            status 204
          end
        end
      end
    end
  end
end

