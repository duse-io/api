require "duse/api/validations/single"

module Duse
  module API
    module Validations
      class Format
        include Single

        def invalid?(subject)
          !subject.nil? && !subject.empty? && subject !~ format
        end

        def error_msg
          "#{subject_name} contains illegal characters"
        end

        def format
          options[:format]
        end
      end
    end
  end
end

