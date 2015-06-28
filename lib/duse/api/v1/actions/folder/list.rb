require 'duse/api/v1/actions/authenticated'

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
