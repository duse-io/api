require 'duse/api/models/secret'
require 'duse/api/models/share'
require 'duse/api/authorization/secret'
require 'duse/api/entity_errors'
require 'duse/api/errors'

class Secret
  def initialize(current_user)
    @current_user = current_user
  end

  def all
    @current_user.secrets
  end

  def get(id)
    secret = Duse::Models::Secret.find id
    Duse::API::SecretAuthorization.authorize! @current_user, :read, secret
    secret
  rescue ActiveRecord::RecordNotFound
    raise Duse::API::NotFound
  end

  def delete(id)
    secret = get id
    Duse::API::SecretAuthorization.authorize! @current_user, :delete, secret
    secret.destroy
  end

  def update(id, params)
    params = params.sanitize strict: false, current_user: @current_user
    secret = get id
    Duse::API::SecretAuthorization.authorize! @current_user, :update, secret
    if params.key?(:title) || params.key?(:cipher_text)
      secret.last_edited_by = @current_user
    end
    secret.title = params[:title] if params.key? :title
    secret.cipher_text = params[:cipher_text] if params.key? :cipher_text
    entities = [secret]

    if params.key?(:shares) && !params[:shares].nil?
      secret.shares.destroy_all
      entities += create_shares(params[:shares], secret)
    end

    errors = Duse::API::EntityErrors.new(ignored_errors).collect_from(entities)
    entities.each(&:save)

    secret
  rescue ActiveRecord::RecordNotSaved
    raise Duse::API::ValidationFailed, {message: errors}.to_json
  end

  def create(params)
    fail Duse::API::ValidationFailed, {message: ['Your limit of secrets has been reached']}.to_json if @current_user.secrets.length >= 10
    params = params.sanitize current_user: @current_user
    secret = Duse::Models::Secret.new(
      title: params[:title],
      cipher_text: params[:cipher_text],
      last_edited_by: @current_user
    )
    entities = [secret]

    entities += create_shares(params[:shares], secret)

    errors = Duse::API::EntityErrors.new(ignored_errors).collect_from(entities)
    entities.each(&:save)

    secret
  rescue ActiveRecord::RecordNotSaved
    raise Duse::API::ValidationFailed, {message: errors}.to_json
  end

  private

  def ignored_errors
    [
      'Secret must not be blank'
    ]
  end

  def create_shares(raw_shares, secret)
    raw_shares.map do |share|
      user = Duse::Models::User.find share[:user_id]

      Duse::Models::Share.new(
        user: user,
        secret: secret,
        content: share[:content],
        signature: share[:signature],
        last_edited_by: @current_user
      )
    end
  end
end

