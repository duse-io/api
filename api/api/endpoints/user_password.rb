require 'api/endpoints/base'
require 'api/facades/user'

module Duse
  module Endpoints
    class UserPassword < Base
      namespace '/v1' do
        namespace '/users' do
          post '/forgot_password' do
            email = JSON.parse(request_body)['email']
            UserFacade.new.send_forgot_password! email
            status 201
          end

          patch '/password' do
            authenticate
            UserFacade.new(current_user).update_password(request_body)
            status 204
          end
        end
      end
    end
  end
end

