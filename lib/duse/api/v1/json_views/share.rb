module Duse
  module JSONViews
    class Share < JSONView
      property :id
      property :content
      property :signature
      property :last_edited_by_id
    end
  end
end
