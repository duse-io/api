require 'duse/api/validations/single'

module Duse
  module API
    module Validations
      class ModelExists
        include Single

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
    end
  end
end

