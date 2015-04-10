require 'duse/api/models/user'
require 'duse/encryption'

module Duse
  module Models
    class SecretPart < ActiveRecord::Base
      has_many :shares, dependent: :destroy
      belongs_to :secret

      def raw_shares_from(user)
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
