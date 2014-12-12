class Secret
  include DataMapper::Resource

  property :id, Serial
  property :title, String, required: true
  property :required, Integer, required: true

  validates_numericality_of :required, gte: 2

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

  def self.new_full(params, current_user)
    secret = Secret.new(
      title: params[:title],
      required: params[:required],
      last_edited_by: params[:last_edited_by]
    )
    entities = [secret]

    params[:parts].each_with_index do |part, index|
      secret_part = SecretPart.new(index: index, secret: secret)

      part.each do |share|
        user_id = share[:user_id]
        user = User.first(username: 'server') if 'server' == user_id
        user = current_user if 'me' == user_id
        user ||= User.get(user_id)
        entities << Share.new(
          user: user,
          secret_part: secret_part,
          content: share[:share],
          signature: share[:signature]
        )
      end

      entities << secret_part
    end

    entities
  end
end
