require 'duse/models/user'
require 'api/emails/confirmation_email'
require 'api/authorization/user'

class User
  def create(request_body)
    sanitized_json = UserJSON.new(request_body).sanitize
    user = Duse::Models::User.new sanitized_json
    fail Duse::ValidationFailed, { message: user.errors.full_messages }.to_json unless user.valid?
    user.save
    ConfirmationEmail.new(user).send
    user
  end

  def get(id)
    Duse::Models::User.find(id)
  rescue ActiveRecord::RecordNotFound
    raise Duse::NotFound
  end

  def update(current_user, id, request_body)
    user = get id
    Duse::UserAuthorization.authorize! current_user, :update, user
    current_password = JSON.parse(request_body)['current_password']
    fail Duse::ValidationFailed, { message: 'Wrong current password' }.to_json unless user.try(:authenticate, current_password)
    sanitized_json = UserJSON.new(request_body).sanitize(strict: false)
    unless user.update(sanitized_json)
      fail Duse::ValidationFailed, { message: user.errors.full_messages }.to_json
    end
    user
  end

  def delete(current_user, id)
    user = get id
    Duse::UserAuthorization.authorize! current_user, :delete, user
    user.destroy
  end
end

