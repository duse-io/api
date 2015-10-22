require "duse/api/json_validator"
require "duse/api/json_extractor"
require "forwardable"

class DefaultJSON
  extend Forwardable

  attr_reader :validator, :schema
  def_delegator :@json, :[]

  def initialize(json, validator, schema)
    @validator = validator
    @schema = schema
    @json = json
  end

  def validate!(options = {})
    errors = JSONValidator.new(schema, options).validate(@json)

    # only do a semantic check if schema validation successful and validator is provided
    if errors.empty? && !validator.nil?
      errors.merge semantic_errors(options)
    end

    fail Duse::API::ValidationFailed, { message: errors }.to_json unless errors.empty?
  end

  def semantic_errors(options)
    extracted_json = extract
    extracted_json = [extracted_json] if !schema.array?

    extracted_json.map do |hash|
      validator.new(options).validate(OpenStruct.new(hash))
    end.flatten.uniq
  end

  def extract
    @extracted_json ||= JSONExtractor.new(schema).extract(@json)
  end

  def sanitize(options = {})
    validate!(options)
    extract
  end
end

