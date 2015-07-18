require 'duse/api/validations/validation'

class SingleValidation < Validation
  def validate(subject)
    return [error_msg] if invalid?(subject)
    []
  end

  def subject_name
    options[:subject_name]
  end
end
