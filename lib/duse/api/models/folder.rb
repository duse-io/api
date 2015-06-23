require 'duse/api/models/user_secret'

module Duse
  module API
    module Models
      class Folder < ActiveRecord::Base
        belongs_to :parent, class_name: 'Folder'
        has_many :children, class_name: 'Folder', foreign_key: :parent_id
      end
    end
  end
end

