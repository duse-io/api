require 'openssl'
require 'securerandom'

require 'duse/api/models/token'
require 'duse/api/models/user_secret'

module Duse
  module API
    module Models
      class User < ActiveRecord::Base
        has_secure_password

        attr_accessor :password_confirmation

        has_many :tokens
        has_many :confirmation_tokens
        has_many :user_secrets
        has_many :secrets, -> { uniq.order :id }, through: :user_secrets

        validates_uniqueness_of :username
        validates_uniqueness_of :email

        def root_folder
          Folder.new(
            name: self.username,
            subfolders: self.root_folders,
            secrets: secrets.without_folder(self)
          )
        end

        def root_folders
          Folder.where(user: self, parent: nil)
        end

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
          ApiToken.create_safe_token(self)
        end

        def confirm!
          update(confirmed_at: Time.now)
        end

        def confirmed?
          !!confirmed_at
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
            key      = OpenSSL::PKey::RSA.generate(2048)
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
end

