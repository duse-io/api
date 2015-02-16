require 'duse/models/user'
require 'duse/errors'
require 'api/emails/confirmation_email'

class CreateUser
  def execute(params)
    user = Duse::Models::User.new(params.sanitize)
    fail Duse::ValidationFailed, { message: user.errors.full_messages }.to_json unless user.valid?
    user.save
    ConfirmationEmail.new(user).send
    user
  end
end

