require 'duse/api/endpoints/base'
require 'duse/api/json_views/user'
require 'duse/api/actions/user'
require 'duse/api/json/user'
require 'duse/api/models/user'

module Duse
  module API
    module Endpoints
      class Users < Base
        helpers do
          def view(subject, options = {})
            JSONViews::User.new(subject, options.merge({host: request.host}))
          end
        end

        namespace '/v1' do
          namespace '/users' do
            get do
              authenticate!
              json(view(Duse::Models::User.all).render)
            end

            get '/me' do
              authenticate!
              json(view(current_user, type: :full).render)
            end

            get '/server' do
              authenticate!
              json(view(Duse::Models::Server.get, type: :full).render)
            end

            get '/:id' do
              authenticate!
              user = User.new.get params[:id]
              json(view(user, type: :full).render)
            end

            delete '/:id' do
              authenticate!
              User.new.delete current_user, params[:id]
              status 204
            end

            patch '/:id' do
              authenticate!
              user = User.new.update current_user, params[:id], request_json
              json(view(user).render)
            end

            post do
              user = User.new.create request_json
              status 201
              json(view(user, type: :full).render)
            end
          end
        end
      end
    end
  end
end

