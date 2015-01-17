module Duse
  module Endpoints
    class Routes < Grape::API
      get do
        {
          secrets_url: '/secrets',
          users_url:   '/users'
        }
      end
    end
  end
end
