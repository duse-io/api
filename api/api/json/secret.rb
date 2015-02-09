require 'duse/json/json_models'
require 'api/validations/secret_validator'

class SecretJSON < DefaultJSON
  def initialize(*args)
    super(*args)
    self.validator = SecretValidator
    self.schema = {
      type: Hash,
      message: 'Secret must be an object',
      properties: {
        title:    { name: 'Title',    type: String },
        parts: {
          name: 'Parts',
          type: Array,
          items: {
            name: 'Shares',
            type: Array,
            items: {
              name: 'Share',
              type: Hash,
              properties: {
                user_id:   { name: 'User id',   type: [String, Integer], message: 'User id must be "me", "server", or the users id' },
                content:   { name: 'Content',   type: String },
                signature: { name: 'Signature', type: String }
              }
            }
          }
        }
      }
    }
  end
end

