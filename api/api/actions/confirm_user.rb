require 'duse/models/token'
require 'duse/errors'

class ConfirmUser
  def execute(token)
    hash = Encryption.hmac(Duse.config.secret_key, token)
    token = Duse::Models::ConfirmationToken.find_by_token_hash(hash)
    fail Duse::NotFound if token.nil?
    fail Duse::AlreadyConfirmed if token.user.confirmed?
    token.user.confirm!
    token.destroy
  end
end

