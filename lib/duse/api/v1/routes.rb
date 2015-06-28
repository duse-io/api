require 'duse/api/v1/base'
require 'duse/api/v1/routes_dsl'
require 'duse/api/v1/json_views/user'
require 'duse/api/v1/json_views/token'
require 'duse/api/v1/json_views/secret'
require 'duse/api/v1/json_views/folder'
require 'duse/api/v1/json_schemas/user'
require 'duse/api/v1/json_schemas/email'
require 'duse/api/v1/json_schemas/token'
require 'duse/api/v1/json_schemas/password'
require 'duse/api/v1/json_schemas/secret'
require 'duse/api/v1/json_schemas/folder'
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
require 'duse/api/v1/actions/folder/list'
require 'duse/api/v1/actions/folder/create'
require 'duse/api/v1/actions/folder/get'
require 'duse/api/v1/actions/folder/update'
require 'duse/api/v1/actions/folder/delete'

module Duse
  module API
    module V1
      class Routes
        extend RoutesDSL

        namespace :v1 do
          get '/' => Actions::Routes

          namespace :users do
            # first match, first hit -> register these routes first, so that
            # /v1/users/:id is not matched
            post  '/confirm'         => Actions::User::ResendConfirmation
            patch '/confirm'         => Actions::User::Confirm
            post  '/forgot_password' => Actions::User::RequestPasswordReset
            patch '/password'        => Actions::User::ResetPassword
            post  '/token'           => Actions::User::CreateAuthToken

            get    '/server' => Actions::User::GetServer
            get    '/me'     => Actions::User::GetMyself
            crud Actions::User
          end

          namespace :secrets do
            crud Actions::Secret
          end

          namespace :folders do
            crud Actions::Folder
          end
        end
      end
    end
  end
end

