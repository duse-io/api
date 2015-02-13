require 'api/endpoints/base'
require 'api/facades/user'

module Duse
  module Endpoints
    class UserConfirmation < Base
      namespace '/v1' do
        namespace '/users' do
          patch '/confirm' do
            confirmation_token = JSON.parse(request_body)['token']
            UserFacade.new.confirm! confirmation_token
            status 204
          end
        end
      end
    end
  end
end

