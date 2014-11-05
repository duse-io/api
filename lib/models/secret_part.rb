class SecretPart
  include DataMapper::Resource

  property :id,    Serial
  property :index, Integer
  
  has n, :shares, constraint: :destroy

  belongs_to :secret
end
