require 'duse/models/user'
require 'api/authorization/user'
require 'duse/errors'
require 'api/emails/confirmation_email'

class UserFacade
  def initialize(current_user = nil)
    @current_user = current_user
  end

  def all
    Duse::Models::User.all
  end

  def get!(id)
    Duse::Models::User.find(id)
  rescue ActiveRecord::RecordNotFound
    raise Duse::NotFound
  end

  def server_user
    Duse::Models::Server.get
  end

  def delete!(id)
    user = get! id
    Duse::UserAuthorization.authorize! @current_user, :delete, user
    user.destroy
  end

  def confirm!(token)
    hash = Encryption.hmac(Duse.config.secret_key, token)
    token = Duse::Models::ConfirmationToken.find_by_token_hash(hash)
    fail Duse::NotFound if token.nil?
    token.user.confirm!
    token.destroy
  end

  def resend_confirmation!(email)
    user = Duse::Models::User.find_by_email email
    fail Duse::NotFound if user.nil?
    user.confirmation_tokens.destroy
    ConfirmationEmail.new(user).send
  end

  def update!(id, params)
    user = get! id
    Duse::UserAuthorization.authorize! @current_user, :update, user
    unless user.update(params.sanitize(strict: false))
      fail Duse::ValidationFailed, { message: user.errors.full_messages }.to_json
    end
    user
  end

  def create!(params)
    user = Duse::Models::User.new(params.sanitize)
    fail Duse::ValidationFailed, { message: user.errors.full_messages }.to_json unless user.valid?
    user.save
    ConfirmationEmail.new(user).send
    user
  end
end

