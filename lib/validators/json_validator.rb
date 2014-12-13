require 'set'

class JSONValidator
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

  def self.validate_type(value, schema)
    errors = Set.new
    errors.add(schema[:message]) unless value.is_a? schema[:type]

    if needs_further_validation?(schema[:type]) && value.is_a?(schema[:type])
      errors.merge(validate_further(value, schema))
    end

    errors
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

  def self.validate_multi_type(value, schema)
    errors = Set.new
    types = schema[:type]
    result = false
    types.each { |type| result = true if value.is_a? type }
    errors.add(schema[:message]) if result
    errors
  end

  def self.validate(value, schema)
    if schema[:type].is_a? Array
      return validate_multi_type(value, schema)
    end
    validate_type value, schema
  end
end
