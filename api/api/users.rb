module API
  class Users < Grape::API
    resource :users do
      get do
        authenticate!
        present User.all, with: Entities::User
      end

      get '/me' do
        authenticate!
        present current_user, with: Entities::User, type: :full
      end

      get '/server' do
        authenticate!
        present Server.get, with: Entities::User, type: :full
      end

      get '/:id' do
        authenticate!
        user = User.get!(params[:id])
        present user, with: Entities::User, type: :full
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
        render_api_error! json.errors, 422 unless json.valid?

        user = User.new json.extract
        begin
          user.save
          present user, with: Entities::User, type: :full
        rescue DataMapper::SaveFailureError
          render_api_error! user.errors.full_messages, 422
        end
      end
    end
  end
end
