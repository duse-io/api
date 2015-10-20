require "duse/api/v1/actions/authenticated"
require "duse/api/v1/json_views/folder"

module Duse
  module API
    module V1
      module Actions
        module Folder
          class List < Actions::Authenticated
            status 200
            render JSONViews::Folder, type: :full

            def call
              [current_user.root_folder]
            end
          end
        end
      end
    end
  end
end
