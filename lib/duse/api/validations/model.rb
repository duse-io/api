require "duse/api/validations/base"

module Duse
  module API
    module Validations
      class Model
        include Base

        def self.validate(validation, *attributes, **options)
          validations << [validation, attributes, options]
        end

        def self.validations
          @validations ||= []
        end

        def validate(subject)
          validations.map do |args|
            run_single_validation(subject, *args)
          end.flatten.compact
        end

        def run_single_validation(subject, validation, attributes, config_options)
          if run_validation?(config_options, @options)
            validation.new(*attributes, @options.merge(config_options)).validate(subject)
          end
        end

        def run_validation?(config_options, execution_options)
          config_options[:on].nil? || config_options[:on] == execution_options[:action]
        end

        def validations
          self.class.validations
        end
      end
    end
  end
end

