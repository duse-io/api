require "duse/api/validations/single"

module Duse
  module API
    module Validations
      class LengthBetween
        include Single

        def invalid?(subject)
          !subject.nil? && !subject.empty? && !subject.length.between?(min, max)
        end

        def error_msg
          "#{subject_name} must be between #{min} and #{max} characters long"
        end

        def min
          options[:min]
        end

        def max
          options[:max]
        end
      end
    end
  end
end

