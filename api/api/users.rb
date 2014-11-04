module API
  class Users < Grape::API
    resource :users do
      get '/:id' do
        authenticate!
        User.get! params[:id]
      end
    end
  end
end
