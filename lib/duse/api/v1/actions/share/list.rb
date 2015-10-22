require "duse/api/v1/actions/authenticated"
require "duse/api/v1/json_views/folder"

module Duse
  module API
    module V1
      module Actions
        module Share
          class List < Actions::Authenticated
            status 200
            render JSONViews::Share, type: :full

            def call
              Models::Share.where(user: current_user)
            end
          end
        end
      end
    end
  end
end
