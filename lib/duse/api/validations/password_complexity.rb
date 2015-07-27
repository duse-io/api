require 'duse/api/validations/base'

module Duse
  module API
    module Validations
      class PasswordComplexity
        include Base

        def validate(password)
          if (/.*[[:punct:]\W]+.*/ =~ password).nil? || # special chars
              (/.*[[:upper:]]+.*/  =~ password).nil? || # upper chars
              (/.*[[:lower:]]+.*/  =~ password).nil? || # lower chars
              (/.*\d+.*/           =~ password).nil?    # digits
            return ['Password too weak']
          end
          []
        end
      end
    end
  end
end

