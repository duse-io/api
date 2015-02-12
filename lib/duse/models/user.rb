require 'openssl'
require 'securerandom'

require 'duse/models/token'

module Duse
  module Models
    class User < ActiveRecord::Base
      has_secure_password

      before_create :set_new_confirmation_token

      attr_accessor :password_confirmation

      has_many :tokens
      has_many :shares
      has_many :secret_parts, through: :shares
      has_many :secrets, through: :secret_parts

      validates_uniqueness_of :username
      validates_uniqueness_of :email

      def public_key
        OpenSSL::PKey::RSA.new read_attribute(:public_key)
      end

      def encrypt(signing_key, text)
        Encryption.encrypt(signing_key, public_key, text)
      end

      def verify_authenticity(signature, text)
        Encryption.verify(public_key, signature, text)
      end

      def has_access_to_secret?(secret)
        secrets.include? secret
      end

      def create_new_token
        raw_token, token_hash = Duse::Models::Token.generate_save_token
        tokens << Duse::Models::Token.create(token_hash: token_hash)
        raw_token
      end

      def set_new_confirmation_token
        self.confirmation_token = SecureRandom.base64(32)
      end
    end

    class Server < User

      def private_key
        OpenSSL::PKey::RSA.new read_attribute(:private_key)
      end

      class << self
        def get
          Server.find_or_create
        end

        def find_or_create
          user = Server.first
          user = create_server_user if user.nil?
          user
        end
        alias_method :ensure_user_exists, :find_or_create

        def create_server_user
          key      = OpenSSL::PKey::RSA.generate(1024)
          password = SecureRandom.base64(32)
          Server.create(
            username: 'server',
            email: 'server@localhost',
            password: password,
            public_key: key.public_key.to_s,
            private_key: key.to_pem
          )
        end

        def public_key
          Server.get.public_key
        end

        def private_key
          Server.get.private_key
        end
      end
    end
  end
end

