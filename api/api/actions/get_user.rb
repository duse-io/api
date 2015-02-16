require 'duse/models/user'
require 'duse/errors'

class GetUser
  def execute(id)
    Duse::Models::User.find(id)
  rescue ActiveRecord::RecordNotFound
    raise Duse::NotFound
  end
end

