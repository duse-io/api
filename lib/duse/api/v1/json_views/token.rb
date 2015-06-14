require 'duse/api/json_view'

module Duse
  module API
    module V1
      module JSONViews
        class Token < JSONView
          property :api_token
        end
      end
    end
  end
end

