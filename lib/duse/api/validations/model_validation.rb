require 'duse/api/validations/validation'

class ModelValidation < Validation
  def self.validate(validation, attribute, options = {})
    validations << [validation, attribute, options]
  end

  def self.validations
    @validations ||= []
  end

  def validate(subject)
    validations.map do |(validation, attribute, options)|
      validation.new(attribute, {
        subject_name: attribute.to_s.capitalize
      }.merge(@options).merge(options)).validate(subject)
    end.flatten
  end

  def validations
    self.class.validations
  end
end
