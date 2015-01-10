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
    unless hash.nil?
      schema[:properties].each do |key, sub_schema|
        result[key] = extract_value(hash[key], sub_schema) unless strict? && hash[key].nil?
      end
    end
    result
  end

  def extract_array(array, schema)
    result = []
    unless array.nil?
      array.each do |value|
        result << extract_value(value, schema[:items])
      end
    end
    result
  end
end
