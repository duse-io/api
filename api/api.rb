require 'duse'
require 'duse/errors'
require 'duse/entity_errors'
require 'duse/authorization'
require 'duse/encryption'
require 'duse/json/json_validator'
require 'duse/json/json_extractor'
require 'duse/json/json_models'
require 'duse/json/json_view'
require 'api/facades/secret'
require 'api/facades/user'
require 'api/validations/secret_validator'
require 'api/validations/user_validator'
require 'api/warden_strategies/api_token'
require 'api/warden_strategies/password'
require 'api/endpoints/helpers'
require 'api/endpoints/base'
require 'api/endpoints/secrets'
require 'api/endpoints/users'
require 'api/endpoints/routes'
require 'api/authorization/secret'
require 'api/authorization/user'
require 'api/json_views/user'
require 'api/json_views/secret'
require 'api/json/secret'
require 'api/json/user'

module Duse
  class API < Endpoints::Base
    use Endpoints::Routes
    use Endpoints::Secrets
    use Endpoints::Users
  end
end

