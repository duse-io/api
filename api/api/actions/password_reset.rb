require 'duse/models/token'
require 'duse/errors'
require 'api/json/user'
require 'api/emails/forgot_password_email'

class User
  class PasswordReset
    def request_reset(email)
      user = Duse::Models::User.find_by_email email
      fail Duse::NotFound if user.nil?
      Duse::Models::ForgotPasswordToken.delete_all(user: user)
      ForgotPasswordEmail.new(user).send
    end

    def reset(request_body)
      raw_token = JSON.parse(request_body)['token']
      token = Duse::Models::ForgotPasswordToken.find_by_raw_token raw_token
      fail Duse::NotFound if token.nil?
      user = token.user
      token.destroy

      password = UserJSON.new(request_body).sanitize(strict: false)[:password]
      user.update(password: password)
    end
  end
end

