require 'duse/api/authorization/base'

module Duse
  module API
    module Authorization
      class Folder < Authorization::Base
        allow :read do |user, folder|
          !folder.nil? && folder.user.id == user.id
        end

        allow :update do |user, folder|
          !folder.nil? && folder.user.id == user.id
        end

        allow :delete do |user, folder|
          !folder.nil? && folder.user.id == user.id
        end
      end
    end
  end
end

