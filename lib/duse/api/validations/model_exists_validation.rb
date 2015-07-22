require 'duse/api/validations/single_validation'

class ModelExistsValidation < SingleValidation
  def invalid?(subject)
    !subject.nil? && !model_class.exists?(subject)
  end

  def error_msg
    "#{subject_name} does not exist"
  end

  def model_class
    options[:model_class]
  end
end
