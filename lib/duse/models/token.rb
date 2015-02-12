require 'openssl'
require 'securerandom'
require 'duse'

module Duse
  module Models
    class Token < ActiveRecord::Base
      before_save :renew_last_used
      belongs_to :user

      def still_valid?
        self.last_used_at > 30.days.ago
      end

      def use!
        renew_last_used
        save
      end

      def renew_last_used
        self.last_used_at = Time.now
      end

      class << self
        def generate_save_token
          token = nil
          token_hash = nil
          loop do
            token = SecureRandom.urlsafe_base64(15).tr('lIO0', 'sxyz')
            token_hash = Encryption.hmac(Duse.config.secret_key, token)
            break if find_by_token_hash(token_hash).nil?
          end
          [token, token_hash]
        end
      end
    end

    class ApiToken < Token
    end

    class ConfirmationToken < Token
    end
  end
end

