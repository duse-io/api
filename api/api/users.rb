module API
  class Users < Grape::API
    resource :users do
      desc 'Retrieve all users.'
      get do
        authenticate!
        present Model::User.all, with: Entities::User
      end

      desc 'Retrieve a single user'
      get '/:id' do
        authenticate!
        user = Model::User.get!(params[:id])
        present user, with: Entities::User, type: :full
      end

      desc 'Create a new user'
      post do
        user = Model::User.new(
          username: params[:username],
          api_token: params[:api_token]
        )
        user.password = params[:password]
        render_api_error! user.errors, 422 unless user.valid?
        user.save
        status 201
        present user, with: Entities::User, type: :full
      end
    end
  end
end
