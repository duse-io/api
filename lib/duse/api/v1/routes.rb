require 'duse/api/v1/base'

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
            post   201, nil,                   JSONViews::Token, '/token',           User::CreateAuthToken
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

