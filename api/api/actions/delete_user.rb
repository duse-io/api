require 'duse/models/user'
require 'duse/errors'
require 'api/authorization/user'

class DeleteUser
  def execute(current_user, id)
    user = GetUser.new.execute id
    Duse::UserAuthorization.authorize! current_user, :delete, user
    user.destroy
  end
end

