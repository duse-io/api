module Model
  class User
    include DataMapper::Resource

    property :id,         Serial
    property :username,   String, required: true
    property :api_token,  String, index: true
    property :public_key, Text,   index: true

    has n, :shares
  end
end
