module Duse
  module Endpoints
    class UserToken < Grape::API
      resource :users do
        resource :token do
          post '/' do
            authenticate! :password
            { api_token: current_user.create_new_token }
          end
        end
      end
    end
  end
end

