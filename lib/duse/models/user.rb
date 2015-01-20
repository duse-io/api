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

      validates_with_method :public_key,
                            method: :validate_public_key,
                            if: ->(user) { !user.public_key.nil? }

      validates_with_method :password_confirmation,
                            method: :validate_password_complexity,
                            if: ->(user) { user.new? && !user.password.nil? }

      validates_with_method :password_confirmation,
                            method: :validate_password_equalness,
                            if: ->(user) { user.new? && !user.password.nil? }

      validates_length_of :password_confirmation,
                          min: 8,
                          if: ->(user) { user.new? && !user.password.nil? },
                          message: 'Password must be at least 8 characters long'

      validates_length_of :username,
                          within: 4..30,
                          if: ->(user) { !user.username.nil? }

      validates_format_of :username,
                          with: /[a-zA-Z0-9_-]+$/,
                          message: 'Username must be only letters, numbers, "-" and "_"'

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

      def validate_password_equalness
        unless password == password_confirmation
          return [false, 'Password and password confirmation do not match']
        end
        true
      end

      def validate_password_complexity
        if (/.*[[:punct:]\W]+.*/ =~ password_confirmation).nil? || # special chars
           (/.*[[:upper:]]+.*/   =~ password_confirmation).nil? || # upper chars
           (/.*[[:lower:]]+.*/   =~ password_confirmation).nil? || # lower chars
           (/.*\d+.*/            =~ password_confirmation).nil?    # digits
          return [false, 'Password too weak.']
        end
        true
      end

      def validate_public_key
        key = OpenSSL::PKey::RSA.new public_key
        fail OpenSSL::PKey::RSAError unless key.public?
        return true
      rescue OpenSSL::PKey::RSAError
        return [false, 'Public key is not a valid RSA Public Key.']
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
            password_confirmation: password,
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