require 'duse/models/user'
require 'api/authorization/user'
require 'duse/errors'
require 'api/emails/verification_email'

class UserFacade
  def initialize(current_user)
    @current_user = current_user
  end

  def all
    Duse::Models::User.all
  end

  def get!(id)
    Duse::Models::User.find(id)
  end

  def server_user
    Duse::Models::Server.get
  end

  def delete!(id)
    user = Duse::Models::User.find(id)
    Duse::UserAuthorization.authorize! @current_user, :delete, user
    user.destroy
  end

  def update!(id, params)
    user = Duse::Models::User.find(id)
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
    VerificationEmail.new(user).send
    user
  end
end

