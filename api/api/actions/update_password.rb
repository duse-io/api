require 'duse/models/token'
require 'duse/errors'
require 'api/json/user'

class UpdatePassword
  def execute(current_user, request_body)
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

