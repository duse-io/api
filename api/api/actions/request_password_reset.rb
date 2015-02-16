require 'duse/models/token'
require 'duse/errors'
require 'api/json/user'
require 'api/emails/forgot_password_email'

class RequestPasswordReset
  def execute(email)
    user = Duse::Models::User.find_by_email email
    fail Duse::NotFound if user.nil?
    Duse::Models::ForgotPasswordToken.delete_all(user: user)
    ForgotPasswordEmail.new(user).send
  end
end

