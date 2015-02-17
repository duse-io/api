require 'duse/models/token'
require 'api/emails/html_email'
require 'forwardable'

class ConfirmationEmail
  extend Forwardable
  def_delegators :@mail, :send

  def initialize(user)
    @mail = HtmlEmail.new(
      subject: 'Confirm your signup',
      recipient: user.email,
      html_body: "Use the following command to confirm your account: duse account confirm --token #{create_confirmation_token(user)}"
    )
  end

  private

  def create_confirmation_token(user)
    Duse::Models::ConfirmationToken.create_safe_token(user)
  end
end

