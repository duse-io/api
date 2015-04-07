require 'duse/api/json_models'
require 'duse/api/validations/user_validator'

class UserJSON < DefaultJSON
  def initialize(json)
    super(json, UserValidator, JSONSchema.new({
      type: Hash,
      message: 'User must be an object',
      properties: {
        username:   { type: String },
        email:      { type: String },
        password:   { type: String },
        public_key: { type: String, name: 'Public key' }
      }
    }))
  end
end

