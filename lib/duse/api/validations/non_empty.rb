require "duse/api/validations/single"

module Duse
  module API
    module Validations
      class NonEmpty
        include Single

        def invalid?(subject)
          !subject.nil? && subject.empty?
        end

        def error_msg
          "#{subject_name} must not be blank"
        end
      end
    end
  end
end

