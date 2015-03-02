class JSONExtractor
  def initialize(schema)
    @schema  = schema
  end

  def extract(value)
    extract_value(value, @schema)
  end

  private

  def extract_value(value, schema)
    return nil if value.nil?
    return extract_hash(value, schema)  if schema.hash?
    return extract_array(value, schema) if schema.array?
    value # if not hash or array this is the recursion anchor
  end

  def extract_hash(hash, schema)
    result = {}
    schema.properties.each do |key, sub_schema|
      result[key] = extract_value(hash[key], sub_schema) if !hash[key].nil?
    end
    result
  end

  def extract_array(array, schema)
    result = []
    array.each do |value|
      result << extract_value(value, schema.items)
    end
    result
  end
end

