require 'duse/json/json_models'
require 'api/validations/user_validator'

class UserJSON < DefaultJSON
  def validator
    UserValidator
  end

  def schema
    {
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

