module Model
  class Share
    include DataMapper::Resource

    property :content, Text
    
    belongs_to :secret_part, key: true
    belongs_to :user,        key: true
  end
end
