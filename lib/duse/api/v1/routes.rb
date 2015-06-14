require 'duse/api/v1/base'
require 'duse/api/v1/routes_dsl'
require 'duse/api/v1/json_views/user'
require 'duse/api/v1/json_views/token'
require 'duse/api/v1/json_views/secret'
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
      class Routes < Base
        extend RoutesDSL

        namespace :v1 do
          namespace :users do
            get    200, nil,                   JSONViews::User,  '/',                User::List
            post   201, JSONSchemas::User,     JSONViews::User,  '/',                User::Create
            get    200, nil,                   JSONViews::User,  '/server',          User::GetServer
            get    200, nil,                   JSONViews::User,  '/me',              User::GetMyself
            get    200, nil,                   JSONViews::User,  '/:id',             User::Get
            update 200, JSONSchemas::User,     JSONViews::User,  '/:id',             User::Update
            delete 204, nil,                   nil,              '/:id',             User::Delete
            post   204, JSONSchemas::Email,    nil,              '/confirm',         User::ResendConfirmation
            patch  204, JSONSchemas::Token,    nil,              '/confirm',         User::Confirm
            post   204, JSONSchemas::Email,    nil,              '/forgot_password', User::RequestPasswordReset
            patch  204, JSONSchemas::Password, nil,              '/password',        User::ResetPassword
            post   201, nil,                   JSONViews::Token, '/token',           User::CreateAuthToken, auth: :password
          end

          namespace :secrets do
            get    200, nil,                 JSONViews::Secret, '/',    Secret::List
            post   201, JSONSchemas::Secret, JSONViews::Secret, '/',    Secret::Create
            get    200, nil,                 JSONViews::Secret, '/:id', Secret::Get
            update 200, JSONSchemas::Secret, JSONViews::Secret, '/:id', Secret::Update
            delete 204, nil,                 nil,               '/:id', Secret::Delete
          end
        end
      end
    end
  end
end

