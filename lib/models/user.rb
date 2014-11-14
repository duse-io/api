require 'bcrypt'
require 'securerandom'

module Model
  class User
    include DataMapper::Resource
    include BCrypt

    before :create, :set_token

    property :id,         Serial
    property :username,   String,     required: true, index: true
    property :password,   BCryptHash, required: true
    property :api_token,  String,     index: true
    property :public_key, Text

    has n, :shares

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
  end
end
