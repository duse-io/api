require "duse/api/v1/actions/base"
require "duse/api/v1/json_views/route"

module Duse
  module API
    module V1
      module Actions
        class Routes < Actions::Base
          status 200
          render JSONViews::Route

          def call
            V1::Routes.endpoints
          end
        end
      end
    end
  end
end
