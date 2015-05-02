require 'duse/api/models/user'
require 'duse/encryption'

module Duse
  module Models
    class Secret < ActiveRecord::Base
      has_many :shares, dependent: :destroy
      has_many :users, -> { uniq.order :id }, through: :shares
      belongs_to :last_edited_by, class_name: 'User', foreign_key: :last_edited_by_id

      def shares_for(user)
        server_share = shares.where(user: Server.get).first
        server_share = Encryption.decrypt(
          Server.private_key, server_share.content
        )
        server_share, _ = Encryption.encrypt(
          Server.private_key, user.public_key, server_share
        )
        shares.where(user: user).map(&:content).prepend server_share
      end
    end
  end
end

