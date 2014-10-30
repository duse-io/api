class Secret
  include DataMapper::Resource

  property :id,       Serial
  property :title,    String
  property :required, Integer
  property :split,    Integer # max length of a secret part

  has n, :secret_parts
end
