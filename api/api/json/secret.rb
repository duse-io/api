require 'duse/json/json_models'
require 'api/validations/secret_validator'

class SecretJSON < DefaultJSON
  def initialize(json)
    super(json, SecretValidator, {
      type: Hash,
      message: 'Secret must be an object',
      properties: {
        title: { type: String },
        parts: {
          type: Array,
          allow_empty: false,
          items: {
            name: 'Shares',
            type: Array,
            items: {
              name: 'Share',
              type: Hash,
              properties: {
                user_id:   { name: 'User id', type: Integer },
                content:   { type: String },
                signature: { type: String }
              }
            }
          }
        }
      }
    })
  end
end

