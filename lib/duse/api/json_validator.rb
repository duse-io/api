require 'set'

class JSONValidator
  def initialize(schema, options = {})
    @schema  = schema
    @options = options
  end

  def validate(value)
    validate_value(value, @schema)
  end

  def strict?
    if @options.key? :strict
      @options[:strict]
    else
      true
    end
  end

  private

  def validate_value(value, schema)
    return Set.new if value.nil? && !strict?

    if value.nil?
      return Set.new ["#{schema.name} must not be blank"]
    end

    validate_type value, schema
  end

  def validate_type(value, schema)
    errors = Set.new
    unless value.is_a? schema.type
      message = build_message(schema)
      errors.add(message)
    end

    if schema.nested? && value.is_a?(schema.type)
      errors.merge(validate_further(value, schema))
    end

    errors
  end

  def build_message(schema)
    return schema.message if schema.message

    name = schema.name
    type = schema.type
    type_string = type.to_s.downcase
    article = 'aeiou'.include?(type_string[0]) ? 'an' : 'a'
    "#{name} must be #{article} #{type_string}"
  end

  def validate_further(value, schema)
    if schema.hash?
      return validate_properties(value, schema.properties)
    end
    if schema.array?
      return validate_items(value, schema)
    end
  end

  def validate_items(array, schema)
    errors = Set.new

    if !schema.allow_empty? && array.empty?
      errors.add "#{schema.name} must not be empty"
    end

    array.each do |item|
      errors.merge(validate_value(item, schema.items))
    end

    errors
  end

  def validate_properties(hash, schema)
    errors = Set.new

    schema.each do |key, type|
      errors.merge(validate_value(hash[key], type))
    end

    errors
  end
end

