module API
  class Secrets < Grape::API
    resource :secrets do
      get do
        {empty: true}
      end
    end
  end
end
