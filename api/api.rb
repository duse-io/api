require 'api/endpoints/base'
require 'api/endpoints/secrets'
require 'api/endpoints/users'
require 'api/endpoints/routes'
require 'api/middlewares/version_switch'

module Duse
  class API < Endpoints::Base
    use VersionSwitch
    use Endpoints::Routes
    use Endpoints::Secrets
    use Endpoints::Users
  end
end

