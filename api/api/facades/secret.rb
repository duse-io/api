class SecretFacade
  def initialize(current_user)
    @current_user = current_user
  end

  def all
    Duse::Models::Share.all(user: @current_user).secret_part.secret
  end

  def get!(id)
    secret = Duse::Models::Secret.get! id
    Duse::SecretAuthorization.authorize! @current_user, :read, secret
    secret
  end

  def delete!(id)
    secret = Duse::Models::Secret.get! id
    Duse::SecretAuthorization.authorize! @current_user, :delete, secret
    secret.destroy
  end

  def update!(id, params)
    params = params.sanitize strict: false, current_user: @current_user
    secret = Duse::Models::Secret.get!(id)
    Duse::SecretAuthorization.authorize! @current_user, :update, secret
    secret.last_edited_by = @current_user
    secret.title = params[:title] if params.key? :title
    entities = [secret]

    if params.key?(:parts) && !params[:parts].nil?
      secret.secret_parts.destroy
      entities += create_parts_from_hash(params[:parts], secret)
    end

    errors = EntityErrors.new(ignored_errors).collect_from(entities)
    entities.each(&:save)

    secret
  rescue DataMapper::SaveFailureError
    raise Duse::ValidationFailed, {message: errors}.to_json
  end

  def create!(params)
    params = params.sanitize current_user: @current_user
    secret = Duse::Models::Secret.new(
      title: params[:title],
      last_edited_by: @current_user
    )
    entities = [secret]

    entities += create_parts_from_hash(params[:parts], secret)

    errors = EntityErrors.new(ignored_errors).collect_from(entities)
    entities.each(&:save)

    secret
  rescue DataMapper::SaveFailureError
    raise Duse::ValidationFailed, {message: errors}.to_json
  end

  private

  def ignored_errors
    [
      'Secret must not be blank',
      'Secret part must not be blank'
    ]
  end

  def create_parts_from_hash(parts, secret)
    entities = []

    parts.each_with_index do |part, index|
      secret_part = Duse::Models::SecretPart.new(index: index, secret: secret)

      part.each do |share|
        user_id = share[:user_id]
        user = Duse::Models::User.first(username: 'server') if 'server' == user_id
        user = @current_user if 'me' == user_id
        user ||= Duse::Models::User.get(user_id)
        entities << Duse::Models::Share.new(
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
