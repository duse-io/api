require 'duse/api/validations/validation'

class ModelValidation < Validation
  def self.validate(subject, validation)
    validations << [subject, validation]
  end

  def self.validations
    @validations ||= []
  end

  def validate(subject)
    validations.map do |(attribute, validation)|
      validation.validate(subject.public_send(attribute))
    end.flatten
  end

  def validations
    self.class.validations
  end
end
