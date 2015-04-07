require 'duse/api/models/token'
require 'duse/api/models/user'
require 'duse/api/errors'
require 'duse/api/emails/confirmation_email'

class User
  class Confirmation
    def resend(params)
      user = Duse::Models::User.find_by_email params[:email]
      fail Duse::NotFound if user.nil?
      fail Duse::AlreadyConfirmed if user.confirmed?
      Duse::Models::ConfirmationToken.delete_all(user: user)
      ConfirmationEmail.new(user).send
    end

    def confirm(params)
      token = Duse::Models::ConfirmationToken.find_by_raw_token params[:token]
      fail Duse::NotFound if token.nil?
      fail Duse::AlreadyConfirmed if token.user.confirmed?
      token.user.confirm!
      token.destroy
    end
  end
end

