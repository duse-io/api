require 'openssl'
require 'securerandom'
require 'dm-types/public_key'

class User
  include DataMapper::Resource
  include BCrypt

  before :create, :set_new_token

  property :id,         Serial
  property :username,   String,     required: true, index: true
  property :password,   BCryptHash, required: true
  property :api_token,  String,     index: true
  property :public_key, PublicKey,  required: true
  property :private_key,Text

  has n, :shares

  validates_with_method :public_key, method: :validate_public_key

  def set_new_token
    self.api_token = generate_save_token
  end

  private

  def generate_save_token
    begin
      token = SecureRandom.urlsafe_base64(15).tr('lIO0', 'sxyz')
    end until User.first(api_token: token).nil?
    token
  end

  def validate_public_key
    begin
      key = OpenSSL::PKey::RSA.new self.public_key
      fail OpenSSL::PKey::RSAError unless key.public?
      return true
    rescue OpenSSL::PKey::RSAError
      return [false, 'Public key is not a valid RSA Public Key.']
    end
  end
end
