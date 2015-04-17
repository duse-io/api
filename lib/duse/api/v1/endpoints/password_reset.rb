require 'duse/api/v1/endpoints/base'
require 'duse/api/v1/actions/password_reset'

module Duse
  module API
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
end

