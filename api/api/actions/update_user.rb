require 'duse/models/user'
require 'duse/errors'
require 'api/actions/get_user'
require 'api/authorization/user'

class UpdateUser
  def execute(current_user, id, params)
    user = GetUser.new.execute id
    Duse::UserAuthorization.authorize! current_user, :update, user
    unless user.update(params.sanitize(strict: false))
      fail Duse::ValidationFailed, { message: user.errors.full_messages }.to_json
    end
    user
  end
end

