module Duse
  module Models
    class Share
      include DataMapper::Resource

      property :content,   Text, required: true
      property :signature, Text, required: true

      belongs_to :secret_part, key: true
      belongs_to :user,        key: true
    end
  end
end
