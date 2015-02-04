module Duse
  module Endpoints
    class UserToken < Endpoints::Base
      namespace '/v1' do
        namespace '/users' do
          namespace '/token' do
            post do
              authenticate! :password
              status 201
              json({ api_token: current_user.create_new_token })
            end
          end
        end
      end
    end
  end
end

