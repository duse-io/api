require 'duse/models/token'
require 'duse/models/user'
require 'duse/errors'
require 'api/emails/confirmation_email'

class ResendConfirmation
  def execute(email)
    user = Duse::Models::User.find_by_email email
    fail Duse::NotFound if user.nil?
    fail Duse::AlreadyConfirmed if user.confirmed?
    Duse::Models::ConfirmationToken.delete_all(user: user)
    ConfirmationEmail.new(user).send
  end
end

