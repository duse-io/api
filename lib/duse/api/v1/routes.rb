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
require 'duse/api/v1/actions/routes'
require 'duse/api/v1/actions/user/list'
require 'duse/api/v1/actions/user/create'
require 'duse/api/v1/actions/user/get_server'
require 'duse/api/v1/actions/user/get_myself'
require 'duse/api/v1/actions/user/get'
require 'duse/api/v1/actions/user/update'
require 'duse/api/v1/actions/user/delete'
require 'duse/api/v1/actions/user/resend_confirmation'
require 'duse/api/v1/actions/user/confirm'
require 'duse/api/v1/actions/user/request_password_reset'
require 'duse/api/v1/actions/user/reset_password'
require 'duse/api/v1/actions/user/create_auth_token'
require 'duse/api/v1/actions/secret/list'
require 'duse/api/v1/actions/secret/create'
require 'duse/api/v1/actions/secret/get'
require 'duse/api/v1/actions/secret/update'
require 'duse/api/v1/actions/secret/delete'

module Duse
  module API
    module V1
      class Routes
        extend RoutesDSL

        namespace :v1 do
          add_endpoint get(200, '/', Actions::Routes).render_with(JSONViews::Route)

          namespace :users do
            # first match, first hit -> register these routes first, so that
            # /v1/users/:id is not matched
            add_endpoint post( 204, '/confirm',         Actions::User::ResendConfirmation  ).validate_with(JSONSchemas::Email)
            add_endpoint patch(204, '/confirm',         Actions::User::Confirm             ).validate_with(JSONSchemas::Token)
            add_endpoint post( 204, '/forgot_password', Actions::User::RequestPasswordReset).validate_with(JSONSchemas::Email)
            add_endpoint patch(204, '/password',        Actions::User::ResetPassword       ).validate_with(JSONSchemas::Password)
            add_endpoint post( 201, '/token',           Actions::User::CreateAuthToken     ).render_with(JSONViews::Token).authenticate(with: :password)

            add_endpoint get(   200, '/',       Actions::User::List     ).render_with(JSONViews::User).authenticate
            add_endpoint post(  201, '/',       Actions::User::Create   ).validate_with(JSONSchemas::User).render_with(JSONViews::User, type: :full)
            add_endpoint get(   200, '/server', Actions::User::GetServer).render_with(JSONViews::User, type: :full).authenticate
            add_endpoint get(   200, '/me',     Actions::User::GetMyself).render_with(JSONViews::User, type: :full).authenticate
            add_endpoint get(   200, '/:id',    Actions::User::Get      ).render_with(JSONViews::User, type: :full).authenticate
            add_endpoint put(   200, '/:id',    Actions::User::Update   ).validate_with(JSONSchemas::User).render_with(JSONViews::User, type: :full).authenticate
            add_endpoint patch( 200, '/:id',    Actions::User::Update   ).validate_with(JSONSchemas::User).render_with(JSONViews::User, type: :full).authenticate
            add_endpoint delete(204, '/:id',    Actions::User::Delete   ).authenticate
          end

          namespace :secrets do
            add_endpoint get(   200, '/',    Actions::Secret::List  ).render_with(JSONViews::Secret).authenticate
            add_endpoint post(  201, '/',    Actions::Secret::Create).validate_with(JSONSchemas::Secret).render_with(JSONViews::Secret).authenticate
            add_endpoint get(   200, '/:id', Actions::Secret::Get   ).render_with(JSONViews::Secret, type: :full).authenticate
            add_endpoint put(   200, '/:id', Actions::Secret::Update).validate_with(JSONSchemas::Secret).render_with(JSONViews::Secret).authenticate
            add_endpoint patch( 200, '/:id', Actions::Secret::Update).validate_with(JSONSchemas::Secret).render_with(JSONViews::Secret).authenticate
            add_endpoint delete(204, '/:id', Actions::Secret::Delete).authenticate
          end
        end
      end
    end
  end
end

