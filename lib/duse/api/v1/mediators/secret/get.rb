require 'duse/api/models/secret'
require 'duse/api/authorization/secret'

module Duse
  module API
    module V1
      module Mediators
        module Secret
          class Get < Mediators::Base
            def call
              secret = Models::Secret.find params[:id]
              SecretAuthorization.authorize! current_user, :read, secret
              secret
            rescue ActiveRecord::RecordNotFound
              raise Sinatra::NotFound
            end
          end
        end
      end
    end
  end
end
