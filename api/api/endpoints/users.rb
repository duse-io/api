module Duse
  module Endpoints
    class Users < Grape::API
      helpers do
        def facade
          UserFacade.new(current_user)
        end
      end

      resource :users do
        get do
          authenticate!
          present facade.all, with: Duse::JSONViews::User
        end

        get '/me' do
          authenticate!
          present current_user, with: Duse::JSONViews::User, type: :full
        end

        get '/server' do
          authenticate!
          present facade.server_user, with: Duse::JSONViews::User, type: :full
        end

        get '/:id' do
          authenticate!
          user = facade.get!(params[:id])
          present user, with: Duse::JSONViews::User, type: :full
        end

        post do
          user = facade.create!(UserJSON.new(params))
          present user, with: Duse::JSONViews::User, type: :full
        end
      end
    end
  end
end
