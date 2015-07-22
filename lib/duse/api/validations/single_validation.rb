require 'duse/api/validations/validation'

class SingleValidation < Validation
  def validate(*subjects)
    return [(options[:msg] || error_msg)] if invalid?(*subjects)
    []
  end

  def subject_name
    options[:subject_name]
  end
end
