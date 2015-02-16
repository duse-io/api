require 'api/endpoints/base'
require 'api/json_views/user'
require 'api/actions/user'
require 'api/json/user'
require 'duse/models/user'

module Duse
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
            user = User.new.update current_user, params[:id], UserJSON.new(request_body)
            json(view(user).render)
          end

          post do
            user = User.new.create UserJSON.new(request_body)
            status 201
            json(view(user, type: :full).render)
          end
        end
      end
    end
  end
end

