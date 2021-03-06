require "duse/api/models/user_secret"

module Duse
  module API
    module Models
      class Folder < ActiveRecord::Base
        has_many :user_secrets, dependent: :nullify
        has_many :secrets, through: :user_secrets
        belongs_to :user
        belongs_to :parent, class_name: "Folder"
        has_many :subfolders, class_name: "Folder", foreign_key: :parent_id, dependent: :destroy
      end
    end
  end
end

