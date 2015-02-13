require 'api/endpoints/base'

module Duse
  module Endpoints
    class UserToken < Base
      namespace '/v1' do
        namespace '/users' do
          post '/token' do
            authenticate! :password
            status 201
            json({ api_token: current_user.create_new_token })
          end
        end
      end
    end
  end
end

