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

class SecretFacade
  def get!(id)
    Secret.get! id
  end

  def update(id, params, current_user)
    secret = Secret.get!(id)
    secret.last_edited_by = current_user
    secret.title = params[:title] if params.key? :title
    entities = [secret]

    if params.key?(:parts) && !params[:parts].nil?
      secret.secret_parts.destroy
      entities += create_parts_from_hash(params[:parts], secret, current_user)
    end

    errors = entity_errors(entities)
    entities.each(&:save)

    secret
  end

  def create(params, current_user)
    secret = Secret.new(
      title: params[:title],
      last_edited_by: current_user
    )
    entities = [secret]

    entities += create_parts_from_hash(params[:parts], secret, current_user)

    @errors = entity_errors(entities)
    entities.each(&:save)

    secret
  end

  def entity_errors(entities)
    errors = Set.new

    entities.each do |entity|
      errors = errors.merge entity.errors.full_messages unless entity.valid?
    end

    # these errors may occur since the entity ids do not exist yet
    errors.subtract [
      'Secret must not be blank',
      'Secret part must not be blank'
    ]
  end

  def errors
    @errors ||= Set.new
  end

  private

  def create_parts_from_hash(parts, secret, current_user)
    entities = []

    parts.each_with_index do |part, index|
      secret_part = SecretPart.new(index: index, secret: secret)

      part.each do |share|
        user_id = share[:user_id]
        user = User.first(username: 'server') if 'server' == user_id
        user = current_user if 'me' == user_id
        user ||= User.get(user_id)
        entities << Share.new(
          user: user,
          secret_part: secret_part,
          content: share[:content],
          signature: share[:signature]
        )
      end

      entities << secret_part
    end

    entities
  end
end
