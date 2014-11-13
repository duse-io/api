require 'bcrypt'

module Model
  class User
    include DataMapper::Resource
    include BCrypt

    property :id,         Serial
    property :username,   String,     required: true, index: true
    property :password,   BCryptHash, required: true
    property :api_token,  String,     required: true, index: true
    property :public_key, Text

    has n, :shares
  end
end
