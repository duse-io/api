module Model
  class SecretPart
    include DataMapper::Resource

    property :id,    Serial
    property :index, Integer

    has n, :shares, constraint: :destroy

    belongs_to :secret

    def raw_shares_from(user)
      users = [Model::User.first(username: 'server'), user]
      shares(user: users).map(&:content)
    end
  end
end
