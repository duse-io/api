require 'duse/models/token'
require 'api/emails/user_email'

class ConfirmationEmail < UserEmail
  def initialize(user)
    super(
      user,
      'Confirm your signup',
      "Use the following command to confirm your account: duse account confirm --token #{create_confirmation_token(user)}"
    )
  end

  private

  def create_confirmation_token(user)
    Duse::Models::ConfirmationToken.create_safe_token(user)
  end
end

