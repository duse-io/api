require 'api/endpoints/base'
require 'api/endpoints/secrets'
require 'api/endpoints/users'
require 'api/endpoints/routes'

module Duse
  class API < Endpoints::Base
    use Endpoints::Routes
    use Endpoints::Secrets
    use Endpoints::Users
  end
end

