require 'duse/api/endpoints/base'

module Duse
  module Endpoints
    class Routes < Base
      get '/v1' do
        json({
          secrets_url: '/secrets',
          users_url:   '/users'
        })
      end
    end
  end
end

