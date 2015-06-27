require 'duse/api/v1/actions/generator'
require 'duse/api/authorization/secret'

module Duse
  module API
    module V1
      module Actions
        module Secret
          Delete = DeleteGenerator.new(self).build
        end
      end
    end
  end
end
