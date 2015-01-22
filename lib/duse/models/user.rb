require 'openssl'
require 'securerandom'
require 'duse/dm-types/rsa_key'

module Duse
  module Models
    class User
      include DataMapper::Resource
      include BCrypt

      before :create, :set_new_token

      attr_accessor :password_confirmation

      property :id,         Serial
      property :username,   String,     required: true, index: true, unique: true
      property :password,   BCryptHash, required: true
      property :api_token,  String,     index:    true, unique: true
      property :public_key, RSAKey,     required: true

      has n, :shares

      def set_new_token
        self.api_token = generate_save_token
      end

      def encrypt(signing_key, text)
        Encryption.encrypt(signing_key, public_key, text)
      end

      def verify_authenticity(signature, text)
        Encryption.verify(public_key, signature, text)
      end

      def has_access_to_secret?(secret)
        !Share.all(user: self).secret_part.secret.get(secret.id).nil?
      end

      private

      def generate_save_token
        token = nil
        loop do
          token = SecureRandom.urlsafe_base64(15).tr('lIO0', 'sxyz')
          break if User.first(api_token: token).nil?
        end
        token
      end
    end

    class Server < User
      property :private_key, RSAKey

      class << self
        def get
          Server.find_or_create
        end

        def find_or_create
          user = Server.first(username: 'server')
          user = create_server_user if user.nil?
          user
        end
        alias_method :ensure_user_exists, :find_or_create

        def create_server_user
          key      = OpenSSL::PKey::RSA.generate(1024)
          password = SecureRandom.base64(32)
          Server.create(
            username: 'server',
            password: password,
            public_key:  key.public_key.to_s,
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
