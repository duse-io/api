class SecretPart
  include DataMapper::Resource

  property :id,    Serial
  property :index, Integer

  has n, :shares, constraint: :destroy

  belongs_to :secret

  validates_uniqueness_of :secret, scope: :index

  def raw_shares_from(user)
    server_share = shares user: Server.get
    server_share = Encryption.decrypt(
      Server.private_key, server_share.first.content
    )
    server_share, _ = Encryption.encrypt(
      Server.private_key, user.public_key, server_share
    )
    shares(user: user).map(&:content).prepend server_share
  end
end
