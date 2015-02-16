require 'api/endpoints/base'
require 'api/actions/request_password_reset'
require 'api/actions/update_password'

module Duse
  module Endpoints
    class UserPassword < Base
      namespace '/v1' do
        namespace '/users' do
          post '/forgot_password' do
            email = JSON.parse(request_body)['email']
            RequestPasswordReset.new.execute email
            status 201
          end

          patch '/password' do
            authenticate
            UpdatePassword.new.execute(current_user, request_body)
            status 204
          end
        end
      end
    end
  end
end

