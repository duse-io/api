require 'duse/api/v1/mediators/base'

module Duse
  module API
    module V1
      module Mediators
        class Routes < Mediators::Base
          def call
            Duse::API::V1::Routes.endpoints
          end
        end
      end
    end
  end
end
