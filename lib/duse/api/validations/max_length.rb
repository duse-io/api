require 'duse/api/validations/single'

module Duse
  module API
    module Validations
      class MaxLength < Single
        def invalid?(subject)
          !subject.nil? && subject.length > max
        end

        def error_msg
          "#{subject_name} must be at most #{max} characters long"
        end

        def max
          options[:max]
        end
      end
    end
  end
end

