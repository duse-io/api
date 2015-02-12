require 'api/endpoints/base'
require 'api/json_views/user'
require 'api/facades/user'
require 'api/json/user'

module Duse
  module Endpoints
    class Users < Base
      helpers do
        def facade
          UserFacade.new(current_user)
        end

        def view(subject, options = {})
          JSONViews::User.new(subject, options.merge({host: request.host}))
        end
      end

      namespace '/v1' do
        namespace '/users' do
          get do
            authenticate!
            json(view(facade.all).render)
          end

          get '/me' do
            authenticate!
            json(view(current_user, type: :full).render)
          end

          get '/server' do
            authenticate!
            json(view(facade.server_user, type: :full).render)
          end

          get '/confirm' do
            content_type 'text/html'
            begin
              facade.confirm! params['token']
            rescue Duse::AlreadyConfirmed
              'Your user has already been confirmed.'
            end
          end

          get '/:id' do
            authenticate!
            user = facade.get!(params[:id])
            json(view(user, type: :full).render)
          end

          delete '/:id' do
            authenticate!
            facade.delete! params[:id]
            status 204
          end

          patch '/:id' do
            authenticate!
            user = facade.update!(params[:id], UserJSON.new(request_body))
            json(view(user).render)
          end

          post '/token' do
            authenticate! :password
            status 201
            json({ api_token: current_user.create_new_token })
          end

          post do
            user = facade.create!(UserJSON.new(request_body))
            status 201
            json(view(user, type: :full).render)
          end
        end
      end
    end
  end
end

