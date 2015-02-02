module Duse
  module Endpoints
    class Users < Grape::API
      helpers do
        def facade
          UserFacade.new(current_user)
        end

        def view(subject, options = {})
          JSONViews::User.new(subject, options.merge({host: 'example.org'}))
        end
      end

      resource :users do
        get do
          authenticate!
          view(facade.all).render
        end

        get '/me' do
          authenticate!
          view(current_user, type: :full).render
        end

        get '/server' do
          authenticate!
          view(facade.server_user, type: :full).render
        end

        get '/:id' do
          authenticate!
          user = facade.get!(params[:id])
          view(user, type: :full).render
        end

        delete '/:id' do
          authenticate!
          facade.delete! params[:id]
          status 204
        end

        patch '/:id' do
          authenticate!
          user = facade.update!(params[:id], UserJSON.new(params))
          view(user).render
        end

        post do
          user = facade.create!(UserJSON.new(params))
          view(user, type: :full).render
        end
      end
    end
  end
end

