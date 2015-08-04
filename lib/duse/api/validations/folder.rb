require 'duse/api/validations/model'
require 'duse/api/validations/multi'
require 'duse/api/validations/format'
require 'duse/api/validations/length_between'

module Duse
  module API
    module Validations
      class Folder < Model
        class Name < Multi
          validate Format, format: /\A[a-zA-Z0-9]+\z/
          validate LengthBetween, min: 1, max: 50
        end

        validate Name, :name, subject_name: 'Folder name'
      end
    end
  end
end

