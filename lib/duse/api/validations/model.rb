require 'duse/api/validations/base'

module Duse
  module API
    module Validations
      class Model
        include Base

        def self.validate(validation, attribute, options = {})
          validations << [validation, attribute, options]
        end

        def self.validations
          @validations ||= []
        end

        def validate(subject)
          validations.map do |(validation, attribute, options)|
            if options[:on].nil? || options[:on] == @options[:action]
              validation.new(attribute, {
                subject_name: attribute.to_s.capitalize
              }.merge(@options).merge(options)).validate(subject)
            end
          end.flatten.compact
        end

        def validations
          self.class.validations
        end
      end
    end
  end
end

