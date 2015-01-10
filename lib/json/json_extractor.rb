class JSONExtractor
  def initialize(schema, options = {})
    @schema  = schema
    @options = options
  end

  def extract(value)
    extract_value(value, @schema)
  end

  def strict?
    if @options.key? :strict
      @options[:strict]
    else
      true
    end
  end

  private

  def extract_value(value, schema)
    return extract_hash(value, schema)  if schema[:type] == Hash
    return extract_array(value, schema) if schema[:type] == Array
    value # if not hash or array this is the recursion anchor
  end

  def extract_hash(hash, schema)
    result = {}
    schema[:properties].each do |key, sub_schema|
      result[key] = extract_value(hash[key], sub_schema) if strict? && !hash[key].nil?
    end
    result
  end

  def extract_array(array, schema)
    result = []
    array.each do |value|
      result << extract_value(value, schema[:items])
    end
    result
  end
end
