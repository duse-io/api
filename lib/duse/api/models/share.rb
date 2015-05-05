module Duse
  module Models
    class Share < ActiveRecord::Base
      belongs_to :secret
      belongs_to :user
      belongs_to :last_edited_by, class_name: 'User', foreign_key: :last_edited_by_id
    end
  end
end

