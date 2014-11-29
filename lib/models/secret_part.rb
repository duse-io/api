class SecretPart
  include DataMapper::Resource

  property :id,    Serial
  property :index, Integer

  has n, :shares, constraint: :destroy

  belongs_to :secret

  validates_uniqueness_of :secret, :scope => :index

  def raw_shares_from(user)
    server_user = User.first(username: 'server')
    server_share = shares user: server_user
    server_private_key = OpenSSL::PKey::RSA.new server_user.private_key
    user_public_key = OpenSSL::PKey::RSA.new user.public_key
    server_share = Encryption.decrypt server_private_key, server_share.first.content
    server_share, signature = Encryption.encrypt server_private_key, user_public_key, server_share
    shares(user: user).map(&:content).prepend server_share
  end
end
