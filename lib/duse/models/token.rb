require 'openssl'
require 'securerandom'

module Duse
  module Models
    class Token < ActiveRecord::Base
      belongs_to :user

      def self.generate_save_token
        token = nil
        token_hash = nil
        loop do
          token = SecureRandom.urlsafe_base64(15).tr('lIO0', 'sxyz')
          token_hash = Encryption.hmac('key', token)
          break if Token.find_by_token_hash(token_hash).nil?
        end
        [token, token_hash]
      end
    end
  end
end

