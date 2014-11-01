class Secret
  include DataMapper::Resource

  property :id, Serial
  property :title, String, required: true
  property :required, Integer, required: true
  # max length of a secret part
  property :split, Integer, required: true

  has n, :secret_parts
end
