require 'duse/api/v1/base'

module Duse
  module API
    module V1
      class Routes < Base
        extend RoutesDSL

        namespace :v1 do
          namespace :users do
            get    200, nil,          JSONViews::Secret, '/',                User::List
            post   201, UserJSON,     JSONViews::Secret, '/',                User::Create
            get    200, nil,          JSONViews::Secret, '/server',          User::GetServer
            get    200, nil,          JSONViews::Secret, '/me',              User::GetMyself
            get    200, nil,          JSONViews::Secret, '/:id',             User::Get
            update 200, UserJSON,     JSONViews::Secret, '/:id',             User::Update
            delete 204, nil,          nil,               '/:id',             User::Delete
            post   204, EmailJSON,    nil,               '/confirm',         User::ResendConfirmation
            patch  204, TokenJSON,    nil,               '/confirm',         User::Confirm
            post   204, EmailJSON,    nil,               '/forgot_password', User::RequestPasswordReset
            patch  204, PasswordJSON, nil,               '/password',        User::ResetPassword
            post   201, nil,          JSONViews::Token,  '/token',           User::CreateAuthToken
          end

          namespace :secrets do
            get    200, nil,        JSONViews::User, '/',    Secret::List
            post   201, SecretJSON, JSONViews::User, '/',    Secret::Create
            get    200, nil,        JSONViews::User, '/:id', Secret::Get
            update 200, SecretJSON, JSONViews::User, '/:id', Secret::Update
            delete 204, nil,        nil,             '/:id', Secret::Delete
          end
        end
      end
    end
  end
end

