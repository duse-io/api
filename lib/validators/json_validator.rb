require 'set'

class JSONValidator
  def self.validate(value, schema)
    if value.nil?
      return Set.new ["#{schema[:name]} must be present"]
    end

    if schema[:type].is_a? Array
      return validate_multi_type(value, schema)
    end
    validate_type value, schema
  end

  private

  def self.validate_multi_type(value, schema)
    errors = Set.new
    types = schema[:type]
    result = false
    types.each { |type| result = true if value.is_a? type }
    errors.add(schema[:message]) unless result
    errors
  end

  def self.validate_type(value, schema)
    errors = Set.new
    unless value.is_a? schema[:type]
      message = build_message(schema)
      errors.add(message)
    end

    if needs_further_validation?(schema[:type]) && value.is_a?(schema[:type])
      errors.merge(validate_further(value, schema))
    end

    errors
  end

  def self.build_message(schema)
    return schema[:message] if schema.has_key? :message

    name = schema[:name]
    type = schema[:type]
    type_string = type.to_s.downcase
    article = 'aeiou'.include?(type_string[0]) ? 'an' : 'a'
    "#{name} must be #{article} #{type_string}"
  end

  def self.needs_further_validation?(type)
    type == Hash || type == Array
  end

  def self.validate_further(value, schema)
    if schema[:type] == Hash
      return validate_properties(value, schema[:properties])
    end
    if schema[:type] == Array
      return validate_items(value, schema[:items])
    end
  end

  def self.validate_items(array, schema)
    errors = Set.new

    array.each do |item|
      errors.merge(validate(item, schema))
    end

    errors
  end

  def self.validate_properties(hash, schema)
    errors = Set.new

    schema.each do |key, type|
      errors.merge(validate(hash[key], type))
    end

    errors
  end
end

class DefaultJSON
  def self.validate(value)
    JSONValidator.validate(value, schema)
  end
end

class SecretJSON < DefaultJSON
  def self.schema
    {
      type: Hash,
      message: 'Secret must be an object',
      properties: {
        title:    { name: 'Title',    type: String},
        required: { name: 'Required', type: Integer},
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
  def self.scheme
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
