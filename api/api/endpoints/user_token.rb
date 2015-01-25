module Duse
  module Endpoints
    class UserToken < Grape::API
      resource :users do
        resource :token do
          post '/' do
            authenticate! :password
            status 200
            { api_token: current_user.api_token }
          end

          post '/regenerate' do
            authenticate!
            current_user.set_new_token
            current_user.save
            { api_token: current_user.api_token }
          end
        end
      end
    end
  end
end

