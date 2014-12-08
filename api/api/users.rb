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
        user = current_user
        user.set_new_token
        user.save
        { api_token: user.api_token }
      end

      post do
        user = User.new(
          username:   params[:username],
          public_key: params[:public_key],
          password:   params[:password],
          password_confirmation: params[:password_confirmation]
        )
        render_api_error! user.errors.full_messages, 422 unless user.valid?
        user.save
        present user, with: Entities::User, type: :full
      end
    end
  end
end
