require 'duse/api/validations/model_validation'
require 'duse/api/validations/multi_validation'
require 'duse/api/validations/format_validation'
require 'duse/api/validations/length_between_validation'

class FolderValidation < ModelValidation
  class NameValidation < MultiValidation
    validate FormatValidation, format: /[a-zA-Z0-9]/
    validate LengthBetweenValidation, min: 1, max: 50
  end

  validate NameValidation, :name, subject_name: 'Folder name'
end

