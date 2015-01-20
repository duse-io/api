class UserFacade
  def initialize(current_user)
    @current_user = current_user
  end

  def all
    Duse::Models::User.all
  end

  def get!(id)
    Duse::Models::User.get!(id)
  end

  def server_user
    Duse::Models::Server.get
  end

  def delete!(id)
    user = Duse::Models::User.get!(id)
    Duse::UserAuthorization.authorize! @current_user, :delete, user
    user.destroy
  end

  def update!(id, params)
    # TODO
  end

  def create!(params)
    user = Duse::Models::User.new(params.sanitize)
    user.save
    user
  rescue DataMapper::SaveFailureError
    raise Duse::ValidationFailed, { message: user.errors.full_messages }.to_json
  end
end
