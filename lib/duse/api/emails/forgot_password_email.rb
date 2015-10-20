require "duse/api/models/token"
require "duse/api/emails/user_email"

class ForgotPasswordEmail < UserEmail
  def initialize(user)
    super(
      user,
      "Reset your password",
      "Use the following command to set a new password: duse account password change --token #{create_forgot_password_token(user)}"
    )
  end

  private

  def create_forgot_password_token(user)
    Duse::API::Models::ForgotPasswordToken.create_safe_token(user)
  end
end

