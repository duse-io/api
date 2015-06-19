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
          get 200, nil, JSONViews::Route, '/', Mediators::Routes, auth: :none

          namespace :users do
            # first match, first hit -> register these routes first, so that
            # /v1/users/:id is not matched
            post   204, JSONSchemas::Email,    nil,              '/confirm',         Mediators::User::ResendConfirmation,   auth: :none
            patch  204, JSONSchemas::Token,    nil,              '/confirm',         Mediators::User::Confirm,              auth: :none
            post   204, JSONSchemas::Email,    nil,              '/forgot_password', Mediators::User::RequestPasswordReset, auth: :none
            patch  204, JSONSchemas::Password, nil,              '/password',        Mediators::User::ResetPassword,        auth: :none
            post   201, nil,                   JSONViews::Token, '/token',           Mediators::User::CreateAuthToken,      auth: :password

            get    200, nil,                   JSONViews::User,  '/',                Mediators::User::List
            post   201, JSONSchemas::User,     JSONViews::User,  '/',                Mediators::User::Create,    type: :full, auth: :none
            get    200, nil,                   JSONViews::User,  '/server',          Mediators::User::GetServer, type: :full
            get    200, nil,                   JSONViews::User,  '/me',              Mediators::User::GetMyself, type: :full
            get    200, nil,                   JSONViews::User,  '/:id',             Mediators::User::Get,       type: :full
            update 200, JSONSchemas::User,     JSONViews::User,  '/:id',             Mediators::User::Update,    type: :full
            delete 204, nil,                   nil,              '/:id',             Mediators::User::Delete
          end

          namespace :secrets do
            get    200, nil,                 JSONViews::Secret, '/',    Mediators::Secret::List
            post   201, JSONSchemas::Secret, JSONViews::Secret, '/',    Mediators::Secret::Create
            get    200, nil,                 JSONViews::Secret, '/:id', Mediators::Secret::Get, type: :full
            update 200, JSONSchemas::Secret, JSONViews::Secret, '/:id', Mediators::Secret::Update
            delete 204, nil,                 nil,               '/:id', Mediators::Secret::Delete
          end
        end
      end
    end
  end
end

