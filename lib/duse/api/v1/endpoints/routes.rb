require 'duse/api/v1/endpoints/base'

module Duse
  module API
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
end

