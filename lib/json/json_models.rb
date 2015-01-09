class DefaultJSON
  def initialize(json)
    @json = json
  end

  def errors
    @errors ||= Set.new
  end

  def valid?
    @errors = JSONValidator.new(schema).validate(@json)

    # only do a semantic check if schema validation successful
    if @errors.empty?
      @errors.merge semantic_errors
    end
    @errors.empty?
  end

  def semantic_errors
    Set.new # by default only validate by schema, no semantic validation
  end

  def extract(options = {})
    JSONExtractor.new(schema, options).extract(@json)
  end
end

class SecretJSON < DefaultJSON
  def semantic_errors
    SecretValidator.validate(@json)
  end

  def schema
    {
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

class UserJSON < DefaultJSON
  def schema
    {
      type: Hash,
      message: 'User must be an object',
      properties: {
        username:              { type: String, name: 'Username' },
        password:              { type: String, name: 'Password' },
        password_confirmation: { type: String, name: 'Password confirmation' },
        public_key:            { type: String, name: 'Public key' }
      }
    }
  end
end
