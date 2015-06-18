require 'duse/api/json_view'

module Duse
  module API
    module V1
      module JSONViews
        class Share < JSONView
          property :id
          property :content
          property :signature
          property :last_edited_by_id
        end
      end
    end
  end
end
