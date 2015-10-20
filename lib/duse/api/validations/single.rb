require "duse/api/validations/base"

module Duse
  module API
    module Validations
      module Single
        def validate(*subjects)
          return [(options[:msg] || error_msg)] if invalid?(*subjects)
          []
        end

        def subject_name
          options[:subject_name]
        end

        def self.included(receiver)
          receiver.send :include, Base
        end
      end
    end
  end
end

