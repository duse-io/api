require 'openssl'
require 'securerandom'

class User
  include DataMapper::Resource
  include BCrypt

  before :create, :set_token

  property :id,         Serial
  property :username,   String,     required: true, index: true
  property :password,   BCryptHash, required: true
  property :api_token,  String,     index: true
  property :public_key, Text,       required: true

  has n, :shares

  validates_with_method :public_key, method: :validate_public_key

  private

  def set_token
    begin
      token = generate_token
    end until User.first(api_token: token).nil?
    self.api_token = token
  end

  def generate_token
    SecureRandom.urlsafe_base64(15).tr('lIO0', 'sxyz')
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
