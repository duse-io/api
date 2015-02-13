require 'api/endpoints/base'
require 'api/facades/user'

module Duse
  module Endpoints
    class UserConfirmation < Base
      namespace '/v1' do
        namespace '/users' do
          get '/confirm' do
            content_type 'text/html'
            begin
              UserFacade.new.confirm! params['token']
            rescue Duse::AlreadyConfirmed
              'Your user has already been confirmed.'
            end
          end
        end
      end
    end
  end
end

