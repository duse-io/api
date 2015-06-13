module Duse
  module API
    module V1
      class Routes < Base
        extend RoutesDSL

        namespace :v1 do
          namespace :users do
            get    '/'                => Mediator::User::List
            post   '/'                => Mediator::User::Create
            get    '/server'          => Mediator::User::GetServer
            get    '/me'              => Mediator::User::GetMyself
            get    '/:id'             => Mediator::User::Get
            patch  '/:id'             => Mediator::User::Update
            delete '/:id'             => Mediator::User::Delete
            post   '/confirm'         => Mediator::User::ResendConfirmation
            patch  '/confirm'         => Mediator::User::Confirm
            post   '/forgot_password' => Mediator::User::RequestPasswordReset
            patch  '/password'        => Mediator::User::ResetPassword
            post   '/token'           => Mediator::User::CreateAuthToken
          end

          namespace :secrets do
            get    '/'    => Mediator::Secret::List
            post   '/'    => Mediator::Secret::Create
            get    '/:id' => Mediator::Secret::Get
            patch  '/:id' => Mediator::Secret::Update
            delete '/:id' => Mediator::Secret::Delete
          end
        end
      end
  end
end

