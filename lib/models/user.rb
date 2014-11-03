class User
  include DataMapper::Resource

  property :id,        Serial
  property :username,  String
  property :api_token, String, index: true

  has n, :shares
end
