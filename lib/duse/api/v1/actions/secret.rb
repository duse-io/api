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
    if !params[:shares].nil?
      params[:shares].each { |s| s[:last_edited_by] = @current_user }
      params[:shares_attributes] = params.delete(:shares) # ActiveRecords makes us do this :(
      secret.shares.delete_all
    end
    if params.key?(:title) || params.key?(:cipher_text)
      secret.last_edited_by = @current_user
    end
    secret.update(params)
    secret.valid?
    errors = secret.errors.full_messages
    secret.save

    secret
  rescue ActiveRecord::RecordNotSaved
    raise Duse::API::ValidationFailed, {message: errors}.to_json
  end

  def create(params)
    fail Duse::API::ValidationFailed, {message: ['Your limit of secrets has been reached']}.to_json if @current_user.secrets.length >= 10
    params = params.sanitize current_user: @current_user
    params[:shares].each { |s| s[:last_edited_by] = @current_user }
    secret = Duse::Models::Secret.new(
      title: params[:title],
      cipher_text: params[:cipher_text],
      last_edited_by: @current_user,
      shares_attributes: params[:shares]
    )

    secret.valid?
    errors = secret.errors.full_messages
    secret.save

    secret
  rescue ActiveRecord::RecordNotSaved
    raise Duse::API::ValidationFailed, {message: errors}.to_json
  end
end

