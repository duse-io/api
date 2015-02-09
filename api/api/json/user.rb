require 'duse/json/json_models'
require 'api/validations/user_validator'

class UserJSON < DefaultJSON
  def initialize(*args)
    super(*args)
    self.validator = UserValidator
    self.schema = {
      type: Hash,
      message: 'User must be an object',
      properties: {
        username:   { type: String, name: 'Username' },
        password:   { type: String, name: 'Password' },
        public_key: { type: String, name: 'Public key' }
      }
    }
  end
end

