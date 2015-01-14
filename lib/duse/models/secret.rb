class Secret
  include DataMapper::Resource

  property :id, Serial
  property :title, String, required: true

  belongs_to :last_edited_by, 'User', required: true
  has n, :secret_parts, constraint: :destroy

  def users
    secret_parts.shares.user
  end

  def secret_parts_for(user)
    secret_parts(order: [:index.asc]).map do |part|
      part.raw_shares_from user
    end
  end
end
