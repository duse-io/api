require 'duse/json/json_validator'
require 'duse/json/json_extractor'

class DefaultJSON
  attr_reader :validator, :schema

  def initialize(json, validator, schema)
    @validator = validator
    @schema = schema
    @json = json
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
    validator.new(options).validate(extract)
  end

  def extract
    @extracted_json ||= JSONExtractor.new(schema).extract(@json)
  end

  def sanitize(options = {})
    validate!(options)
    extract
  end
end

