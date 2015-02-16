require 'api/endpoints/base'
require 'api/actions/user_password'

module Duse
  module Endpoints
    class UserPassword < Base
      namespace '/v1' do
        namespace '/users' do
          post '/forgot_password' do
            email = JSON.parse(request_body)['email']
            User::Password.new.request_reset email
            status 201
          end

          patch '/password' do
            authenticate
            User::Password.new.update(current_user, request_body)
            status 204
          end
        end
      end
    end
  end
end

