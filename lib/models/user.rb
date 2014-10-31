class User
  include DataMapper::Resource

  property :id,       Serial
  property :username, String
  property :api_key,  String

  has n, :shares
end
