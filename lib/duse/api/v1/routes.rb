require 'duse/api/v1/base'
require 'duse/api/v1/routes_dsl'
require 'duse/api/v1/json_views/route'
require 'duse/api/v1/json_views/user'
require 'duse/api/v1/json_views/token'
require 'duse/api/v1/json_views/secret'
require 'duse/api/v1/json_schemas/user'
require 'duse/api/v1/json_schemas/email'
require 'duse/api/v1/json_schemas/token'
require 'duse/api/v1/json_schemas/password'
require 'duse/api/v1/json_schemas/secret'
require 'duse/api/v1/mediators/routes'
require 'duse/api/v1/mediators/user/list'
require 'duse/api/v1/mediators/user/create'
require 'duse/api/v1/mediators/user/get_server'
require 'duse/api/v1/mediators/user/get_myself'
require 'duse/api/v1/mediators/user/get'
require 'duse/api/v1/mediators/user/update'
require 'duse/api/v1/mediators/user/delete'
require 'duse/api/v1/mediators/user/resend_confirmation'
require 'duse/api/v1/mediators/user/confirm'
require 'duse/api/v1/mediators/user/request_password_reset'
require 'duse/api/v1/mediators/user/reset_password'
require 'duse/api/v1/mediators/user/create_auth_token'
require 'duse/api/v1/mediators/secret/list'
require 'duse/api/v1/mediators/secret/create'
require 'duse/api/v1/mediators/secret/get'
require 'duse/api/v1/mediators/secret/update'
require 'duse/api/v1/mediators/secret/delete'

module Duse
  module API
    module V1
      class Routes
        extend RoutesDSL

        namespace :v1 do
          add_endpoint get(200, '/', Mediators::Routes).render_with(JSONViews::Route)

          namespace :users do
            # first match, first hit -> register these routes first, so that
            # /v1/users/:id is not matched
            add_endpoint post( 204, '/confirm',         Mediators::User::ResendConfirmation  ).validate_with(JSONSchemas::Email)
            add_endpoint patch(204, '/confirm',         Mediators::User::Confirm             ).validate_with(JSONSchemas::Token)
            add_endpoint post( 204, '/forgot_password', Mediators::User::RequestPasswordReset).validate_with(JSONSchemas::Email)
            add_endpoint patch(204, '/password',        Mediators::User::ResetPassword       ).validate_with(JSONSchemas::Password)
            add_endpoint post( 201, '/token',           Mediators::User::CreateAuthToken     ).render_with(JSONViews::Token).authenticate(with: :password)

            add_endpoint get(   200, '/',       Mediators::User::List     ).render_with(JSONViews::User).authenticate
            add_endpoint post(  201, '/',       Mediators::User::Create   ).validate_with(JSONSchemas::User).render_with(JSONViews::User, type: :full)
            add_endpoint get(   200, '/server', Mediators::User::GetServer).render_with(JSONViews::User, type: :full).authenticate
            add_endpoint get(   200, '/me',     Mediators::User::GetMyself).render_with(JSONViews::User, type: :full).authenticate
            add_endpoint get(   200, '/:id',    Mediators::User::Get      ).render_with(JSONViews::User, type: :full).authenticate
            add_endpoint put(   200, '/:id',    Mediators::User::Update   ).validate_with(JSONSchemas::User).render_with(JSONViews::User, type: :full).authenticate
            add_endpoint patch( 200, '/:id',    Mediators::User::Update   ).validate_with(JSONSchemas::User).render_with(JSONViews::User, type: :full).authenticate
            add_endpoint delete(204, '/:id',    Mediators::User::Delete   ).authenticate
          end

          namespace :secrets do
            add_endpoint get(   200, '/',    Mediators::Secret::List  ).render_with(JSONViews::Secret).authenticate
            add_endpoint post(  201, '/',    Mediators::Secret::Create).validate_with(JSONSchemas::Secret).render_with(JSONViews::Secret).authenticate
            add_endpoint get(   200, '/:id', Mediators::Secret::Get   ).render_with(JSONViews::Secret, type: :full).authenticate
            add_endpoint put(   200, '/:id', Mediators::Secret::Update).validate_with(JSONSchemas::Secret).render_with(JSONViews::Secret).authenticate
            add_endpoint patch( 200, '/:id', Mediators::Secret::Update).validate_with(JSONSchemas::Secret).render_with(JSONViews::Secret).authenticate
            add_endpoint delete(204, '/:id', Mediators::Secret::Delete).authenticate
          end
        end
      end
    end
  end
end

