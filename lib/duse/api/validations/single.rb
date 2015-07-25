require 'duse/api/validations/base'

module Duse
  module API
    module Validations
      class Single < Base
        def validate(*subjects)
          return [(options[:msg] || error_msg)] if invalid?(*subjects)
          []
        end

        def subject_name
          options[:subject_name]
        end
      end
    end
  end
end

