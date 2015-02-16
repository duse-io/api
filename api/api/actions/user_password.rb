require 'duse/models/token'
require 'duse/errors'
require 'api/json/user'
require 'api/emails/forgot_password_email'

class User
  class Password
    def request_reset(email)
      user = Duse::Models::User.find_by_email email
      fail Duse::NotFound if user.nil?
      Duse::Models::ForgotPasswordToken.delete_all(user: user)
      ForgotPasswordEmail.new(user).send
    end

    def update(current_user, request_body)
      json = JSON.parse(request_body)
      user = current_user
      if user.nil?
        hash = Encryption.hmac(Duse.config.secret_key, json['token'])
        token = Duse::Models::ForgotPasswordToken.find_by_token_hash hash
        fail Duse::NotFound if token.nil?
        user = token.user
        token.destroy
      end

      password = UserJSON.new(request_body).sanitize(strict: false)[:password]
      user.update(password: password)
    end
  end
end

