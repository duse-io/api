class SecretPart
  include DataMapper::Resource

  property :id,    Serial
  property :index, Integer

  has n, :shares, constraint: :destroy

  belongs_to :secret

  def raw_shares_from(users)
    secret_users = [User.first(username: 'server')] + users
    shares(user: secret_users).map(&:content)
  end
end
