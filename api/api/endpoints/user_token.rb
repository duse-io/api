module Duse
  module Endpoints
    class UserToken < Grape::API
      helpers do
        def facade
          TokenFacade.new(current_user)
        end
      end

      resource :users do
        resource :token do
          post '/' do
            authenticate! :password
            { api_token: facade.create! }
          end
        end
      end
    end
  end
end

