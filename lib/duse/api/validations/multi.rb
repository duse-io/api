module Duse
  module API
    module Validations
      class Multi
        def initialize(subject_symbol, options)
          @subject_symbol = subject_symbol
          @options = options
        end

        def self.validate(validation, options = {})
          validations << [validation, options]
        end

        def self.validations
          @validations ||= []
        end

        def validate(subject)
          validations.map do |(validation, inner_options)|
            validation.new({
              subject_name: @subject_symbol.to_s.capitalize
            }.merge(@options).merge(inner_options)).validate(subject.public_send(@subject_symbol))
          end.flatten
        end

        def validations
          self.class.validations
        end
      end
    end
  end
end

