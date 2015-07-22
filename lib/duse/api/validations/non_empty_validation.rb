require 'duse/api/validations/single_validation'

class NonEmptyValidation < SingleValidation
  def invalid?(subject)
    !subject.nil? && subject.empty?
  end

  def error_msg
    "#{subject_name} must not be blank"
  end
end
