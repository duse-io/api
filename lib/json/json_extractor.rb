class JSONExtractor
  def self.extract_hash(hash, schema)
    result = {}
    schema[:properties].each do |key, sub_schema|
      result[key] = extract(hash[key], sub_schema)
    end
    result
  end

  def self.extract_array(array, schema)
    result = []
    array.each do |value|
      result << extract(value, schema[:items])
    end
    result
  end

  def self.extract(value, schema)
    return extract_hash(value, schema) if schema[:type] == Hash
    return extract_array(value, schema) if schema[:type] == Array
    value # if not hash or array this is the recursion anchor
  end
end
