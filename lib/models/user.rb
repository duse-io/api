class User
  include DataMapper::Resource

  property :id,         Serial
  property :username,   String
  property :api_token,  String, index: true
  property :public_key, Text

  has n, :shares
end
