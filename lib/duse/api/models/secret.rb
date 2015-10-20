require "duse/api/models/user"
require "duse/api/models/share"
require "duse/api/models/user_secret"
require "ostruct"

module Duse
  module API
    module Models
      class Secret < ActiveRecord::Base
        has_many :shares, dependent: :destroy
        accepts_nested_attributes_for :shares
        has_many :user_secrets, autosave: true
        has_many :users, -> { uniq.order :id }, through: :user_secrets
        belongs_to :last_edited_by, class_name: "User", foreign_key: :last_edited_by_id

        scope :zombies, -> { joins("LEFT JOIN user_secrets ON user_secrets.secret_id = secrets.id").where("user_secrets.user_id IS NULL") }
        scope :without_folder, ->(user) { joins("LEFT JOIN user_secrets us ON us.secret_id = secrets.id").where("us.folder_id IS NULL AND us.user_id = ?", user.id) }

        def shares_for(user)
          server_share = shares.where(user: Server.get).first
          server_share = Encryption::Asymmetric.decrypt(
            Server.private_key, server_share.content
          )
          server_share, signature = Encryption::Asymmetric.encrypt(
            Server.private_key, user.public_key, server_share
          )
          shares.where(user: user).to_a.prepend OpenStruct.new(content: server_share, signature: signature, last_edited_by_id: Server.get.id)
        end
      end
    end
  end
end

