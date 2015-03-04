require 'api/endpoints/base'
require 'api/actions/password_reset'

module Duse
  module Endpoints
    class PasswordReset < Base
      namespace '/v1' do
        namespace '/users' do
          post '/forgot_password' do
            User::PasswordReset.new.request_reset request_json
            status 201
          end

          patch '/password' do
            User::PasswordReset.new.reset request_json
            status 204
          end
        end
      end
    end
  end
end

