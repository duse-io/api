require 'duse/api/json_view'

module Duse
  module API
    module V1
      module JSONViews
        class Route < JSONView
          property :absolute_route
        end
      end
    end
  end
end
