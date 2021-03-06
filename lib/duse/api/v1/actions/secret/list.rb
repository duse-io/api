require "duse/api/v1/actions/authenticated"
require "duse/api/v1/json_views/secret"

module Duse
  module API
    module V1
      module Actions
        module Secret
          class List < Actions::Authenticated
            status 200
            render JSONViews::Secret

            def call
              current_user.secrets
            end
          end
        end
      end
    end
  end
end
