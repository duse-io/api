class SecretPart
  include DataMapper::Resource

  property :id,    Serial
  property :index, Integer
  
  has n, :shares

  belongs_to :secret
end
