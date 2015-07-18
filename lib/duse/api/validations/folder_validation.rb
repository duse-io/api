require 'duse/api/validations/model_validation'
require 'duse/api/validations/multi_validation'
require 'duse/api/validations/format_validation'
require 'duse/api/validations/length_between_validation'

class FolderValidation < ModelValidation
  class NameValidation < MultiValidation
    validate FormatValidation.new(subject_name: 'Folder name', format: /[a-zA-Z0-9]/)
    validate LengthBetweenValidator.new(subject_name: 'Folder name', min: 1, max: 50)
  end

  validate :name, NameValidation.new
end

