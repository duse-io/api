class DefaultJSON
  def initialize(json)
    @json = JSON.parse(json, symbolize_names: true)
  end

  def validate!(options = {})
    errors = JSONValidator.new(schema, options).validate(@json)

    # only do a semantic check if schema validation successful
    if errors.empty?
      errors.merge semantic_errors(options)
    end

    fail Duse::ValidationFailed, { message: errors }.to_json unless errors.empty?
  end

  def semantic_errors(options)
    Set.new # by default only validate by schema, no semantic validation
  end

  def extract
    JSONExtractor.new(schema).extract(@json)
  end

  def sanitize(options = {})
    validate!(options)
    extract
  end
end

