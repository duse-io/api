require 'openssl'
require 'securerandom'
require 'dm-types/rsa_key'

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

  validates_with_method :public_key,            method: :validate_public_key
  validates_with_method :password_confirmation, method: :validate_password_complexity, if: :new?
  validates_with_method :password_confirmation, method: :validate_password_equalness,  if: :new?
  validates_length_of   :password_confirmation, min: 8, if: :new?, message: 'Password must be at least 8 characters long'
  validates_format_of   :username, with: /[a-zA-Z0-9_-]{4,30}$/,   message: 'Username must be only letters, capital letters, numbers, "-" and "_". And at least 4 characters long.'

  def set_new_token
    self.api_token = generate_save_token
  end

  def validate_password_equalness
    unless password == password_confirmation
      return [false, 'Password and password confirmation do not match']
    end
    true
  end

  def validate_password_complexity
    if (/.*[[:punct:]\W]+.*/ =~ password_confirmation).nil? || # includes punctuation/special chars
       (/.*[[:upper:]]+.*/   =~ password_confirmation).nil? || # includes uppercase letters
       (/.*[[:lower:]]+.*/   =~ password_confirmation).nil? || # includes lowercase letters
       (/.*\d+.*/            =~ password_confirmation).nil?    # includes digits letters
      return [false, 'Password too weak.']
    end
    true
  end

  def encrypt(signing_key, text)
    Encryption.encrypt(signing_key, public_key, text)
  end

  def verify_authenticity(signature, text)
    Encryption.verify(public_key, signature, text)
  end

  private

  def generate_save_token
    begin
      token = SecureRandom.urlsafe_base64(15).tr('lIO0', 'sxyz')
    end until User.first(api_token: token).nil?
    token
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

  validates_with_method :private_key, method: :validate_private_key, if: ->(u) { !u.private_key.nil? }

  class << self
    def get
      Server.find_or_create
    end

    def find_or_create
      user = Server.first(username: 'server')

      if user.nil?
        key = OpenSSL::PKey::RSA.generate(1024)
        public_key = key.public_key.to_s
        private_key = key.to_pem
        password = SecureRandom.base64(32)
        user = Server.create(username: 'server', password: password, password_confirmation: password, public_key: public_key, private_key: private_key)
      end

      user
    end
    alias_method :ensure_user_exists, :find_or_create

    def public_key
      Server.get.public_key
    end

    def private_key
      Server.get.private_key
    end
  end

  private

  def validate_private_key
    key = OpenSSL::PKey::RSA.new private_key
    fail OpenSSL::PKey::RSAError unless key.private?
    return true
  rescue OpenSSL::PKey::RSAError
    return [false, 'Public key is not a valid RSA Private Key.']
  end
end
