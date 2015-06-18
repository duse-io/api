require 'duse/api/json_validator'
require 'duse/api/json_extractor'
require 'forwardable'

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

