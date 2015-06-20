require 'duse/api/v1/actions/base'

module Duse
  module API
    module V1
      module Actions
        class Routes < Actions::Base
          def call
            V1::Routes.endpoints
          end
        end
      end
    end
  end
end
