require 'api/endpoints/secrets'
require 'api/endpoints/users'
require 'api/endpoints/routes'
require 'api/middlewares/v1'

module Duse
  class API < Sinatra::Base
    configure :production do
      enable :logging
    end

    use V1
    use Endpoints::Routes
    use Endpoints::Secrets
    use Endpoints::Users
  end
end

