class SecretPart
  include DataMapper::Resource

  property :index, Integer
  
  has n, :shares

  belongs_to :secret, key: true
end
