require 'duse/models/token'
require 'duse/models/user'
require 'duse/errors'
require 'api/emails/confirmation_email'

class User
  class Confirmation
    def resend(email)
      user = Duse::Models::User.find_by_email email
      fail Duse::NotFound if user.nil?
      fail Duse::AlreadyConfirmed if user.confirmed?
      Duse::Models::ConfirmationToken.delete_all(user: user)
      ConfirmationEmail.new(user).send
    end

    def confirm(raw_token)
      token = Duse::Models::ConfirmationToken.find_by_raw_token raw_token
      fail Duse::NotFound if token.nil?
      fail Duse::AlreadyConfirmed if token.user.confirmed?
      token.user.confirm!
      token.destroy
    end
  end
end

