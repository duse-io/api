require 'duse/api/json_models'
require 'duse/api/json_schema'
require 'duse/api/validations/secret_validator'

class SecretJSON < DefaultJSON
  def initialize(json)
    super(json, SecretValidator, JSONSchema.new({
      type: Hash,
      message: 'Secret must be an object',
      properties: {
        title: { type: String },
        parts: {
          type: Array,
          allow_empty: false,
          items: {
            name: 'Shares',
            allow_empty: false,
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
    }))
  end
end
