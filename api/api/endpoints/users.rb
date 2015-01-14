module API
  class Users < Grape::API
    resource :users do
      get do
        authenticate!
        present User.all, with: Duse::JSONViews::User
      end

      get '/me' do
        authenticate!
        present current_user, with: Duse::JSONViews::User, type: :full
      end

      get '/server' do
        authenticate!
        present Server.get, with: Duse::JSONViews::User, type: :full
      end

      get '/:id' do
        authenticate!
        user = User.get!(params[:id])
        present user, with: Duse::JSONViews::User, type: :full
      end

      post '/token' do
        authenticate! :password
        status 200
        { api_token: current_user.api_token }
      end

      post '/token/regenerate' do
        authenticate!
        current_user.set_new_token
        current_user.save
        { api_token: current_user.api_token }
      end

      post do
        json = UserJSON.new(params)
        json.validate!

        user = User.new json.extract
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
