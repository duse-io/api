require 'duse/api/validations/single_validation'

class FormatValidation < SingleValidation
  def invalid?(subject)
    !subject.nil? && subject !~ format
  end

  def error_msg
    "#{subject_name} contains illegal characters"
  end

  def format
    options[:format]
  end
end
