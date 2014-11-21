module API
  class Users < Grape::API
    resource :users do
      desc 'Retrieve all users.'
      get do
        authenticate!
        present User.all, with: Entities::User
      end

      desc 'Return the authenticated users profile'
      get '/me' do
        authenticate!
        present current_user, with: Entities::User, type: :full
      end

      desc 'Retrieve a single user'
      get '/:id' do
        authenticate!
        user = User.get!(params[:id])
        present user, with: Entities::User, type: :full
      end

      desc 'Retrieve a users api token'
      post '/token' do
        authenticate! :password
        status 200
        {api_token: current_user.api_token}
      end

      desc 'Generate a new users api token'
      post '/token/regenerate' do
        authenticate!
        user = current_user
        user.set_new_token
        user.save
        {api_token: user.api_token}
      end

      desc 'Create a new user'
      post do
        user = User.new(
          username: params[:username],
          api_token: params[:api_token],
          public_key: params[:public_key],
          password: params[:password]
        )
        render_api_error! user.errors, 422 unless user.valid?
        user.save
        present user, with: Entities::User, type: :full
      end
    end
  end
end
