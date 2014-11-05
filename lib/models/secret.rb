class Secret
  include DataMapper::Resource

  property :id, Serial
  property :title, String, required: true
  property :required, Integer, required: true
  # max length of a secret part
  property :split, Integer, required: true

  validates_numericality_of :required, gte: 2
  validates_numericality_of :split, gte: 1

  has n, :secret_parts, constraint: :destroy
end
