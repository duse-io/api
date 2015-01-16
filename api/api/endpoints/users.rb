module Duse
  module Endpoints
    class Users < Grape::API
      resource :users do
        get do
          authenticate!
          present Duse::Models::User.all, with: Duse::JSONViews::User
        end

        get '/me' do
          authenticate!
          present current_user, with: Duse::JSONViews::User, type: :full
        end

        get '/server' do
          authenticate!
          present Duse::Models::Server.get, with: Duse::JSONViews::User, type: :full
        end

        get '/:id' do
          authenticate!
          user = Duse::Models::User.get!(params[:id])
          present user, with: Duse::JSONViews::User, type: :full
        end

        resource :token do
          post '/' do
            authenticate! :password
            status 200
            { api_token: current_user.api_token }
          end

          post '/regenerate' do
            authenticate!
            current_user.set_new_token
            current_user.save
            { api_token: current_user.api_token }
          end
        end

        post do
          json = UserJSON.new(params)
          user = Duse::Models::User.new(json.sanitize)
          begin
            user.save
            present user, with: Duse::JSONViews::User, type: :full
          rescue DataMapper::SaveFailureError
            raise Duse::ValidationFailed, { message: user.errors.full_messages }.to_json
          end
        end
      end
    end
  end
end
