require 'duse/models/token'
require 'api/emails/html_email'
require 'forwardable'

class ForgotPasswordEmail
  extend Forwardable
  def_delegators :@mail, :send

  def initialize(user)
    @mail = HtmlEmail.new(
      subject: 'Reset your password',
      recipient: user.email,
      html_body: "Use the following command to set a new password: duse account password --token #{create_forgot_password_token(user)}"
    )
  end

  private

  def create_forgot_password_token(user)
    Duse::Models::ForgotPasswordToken.create_safe_token(user)
  end
end

