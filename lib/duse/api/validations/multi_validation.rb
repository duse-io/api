require 'duse/api/validations/validation'

class MultiValidation
  def self.validate(validation)
    validations << validation
  end

  def self.validations
    @validations ||= []
  end

  def validate(subject)
    validations.map do |validation|
      validation.validate(subject)
    end.flatten
  end

  def validations
    self.class.validations
  end
end
