module API
  class Users < Grape::API
    resource :users do
      get do
        authenticate!
        Model::User.all
      end

      get '/:id' do
        authenticate!
        Model::User.get! params[:id]
      end

      post do
        user = Model::User.new(
          username: params[:username],
          api_token: params[:api_token]
        )
        render_api_error! user.errors, 422 unless user.valid?
        user.save
        status 201
      end
    end
  end
end
