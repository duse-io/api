require 'duse/api/endpoints/base'
require 'duse/api/actions/secret'
require 'duse/api/json_views/secret'
require 'duse/api/json/secret'

module Duse
  module API
    module Endpoints
      class Secrets < Base
        helpers do
          def actions
            Secret.new(current_user)
          end

          def view(subject, options = {})
            JSONViews::Secret.new(subject, options.merge({host: request.host}))
          end
        end

        namespace '/v1' do
          namespace '/secrets' do
            before { authenticate! }

            get do
              json(view(actions.all).render)
            end

            get '/:id' do
              secret = actions.get(params[:id])
              json(view(secret, type: :full, user: current_user).render)
            end

            delete '/:id' do
              actions.delete params[:id]
              status 204
            end

            patch '/:id' do
              secret = actions.update(params[:id], SecretJSON.new(request_json))
              json(view(secret).render)
            end

            post do
              secret = actions.create(SecretJSON.new(request_json))
              status 201
              json(view(secret).render)
            end
          end
        end
      end
    end
  end
end

