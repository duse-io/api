require 'duse/json/json_models'
require 'api/validations/user_validator'

class UserJSON < DefaultJSON
  def initialize(json)
    super(json, UserValidator, {
      type: Hash,
      message: 'User must be an object',
      properties: {
        username:   { type: String },
        email:      { type: String },
        password:   { type: String },
        public_key: { type: String, name: 'Public key' }
      }
    })
  end
end

