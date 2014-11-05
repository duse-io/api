module API
  class Users < Grape::API
    before { authenticate! }

    resource :users do
      get do
        Model::User.all
      end

      get '/:id' do
        Model::User.get! params[:id]
      end
    end
  end
end
