module API
  class Users < Grape::API
    before { authenticate! }

    resource :users do
      get do
        User.all
      end

      get '/:id' do
        User.get! params[:id]
      end
    end
  end
end
