require 'duse/api/models/user'
require 'duse/api/emails/confirmation_email'
require 'duse/api/authorization/user'

class User
  def create(params)
    sanitized_json = UserJSON.new(params).sanitize
    user = Duse::Models::User.new sanitized_json
    fail Duse::API::ValidationFailed, { message: user.errors.full_messages }.to_json if !user.valid?
    user.save
    ConfirmationEmail.new(user).send
    user
  end

  def get(id)
    Duse::Models::User.find(id)
  rescue ActiveRecord::RecordNotFound
    raise Duse::API::NotFound
  end

  def update(current_user, id, params)
    user = get id
    Duse::API::UserAuthorization.authorize! current_user, :update, user
    current_password = params[:current_password]
    fail Duse::API::ValidationFailed, { message: 'Wrong current password' }.to_json if !user.try(:authenticate, current_password)
    sanitized_json = UserJSON.new(params).sanitize(strict: false)
    if !user.update(sanitized_json)
      fail Duse::API::ValidationFailed, { message: user.errors.full_messages }.to_json
    end
    user
  end

  def delete(current_user, id)
    user = get id
    Duse::API::UserAuthorization.authorize! current_user, :delete, user
    user.destroy
  end
end

