require 'duse/api/models/token'
require 'duse/api/errors'
require 'duse/api/emails/forgot_password_email'
require 'duse/api/v1/json/user'

class User
  class PasswordReset
    def request_reset(params)
      user = Duse::Models::User.find_by_email params[:email]
      fail Duse::NotFound if user.nil?
      Duse::Models::ForgotPasswordToken.delete_all(user: user)
      ForgotPasswordEmail.new(user).send
    end

    def reset(params)
      raw_token = params[:token]
      token = Duse::Models::ForgotPasswordToken.find_by_raw_token raw_token
      fail Duse::NotFound if token.nil?
      user = token.user
      token.destroy

      password = UserJSON.new(params).sanitize(strict: false)[:password]
      user.update(password: password)
    end
  end
end

