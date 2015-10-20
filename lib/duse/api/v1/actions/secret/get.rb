require "duse/api/v1/actions/generator"
require "duse/api/models/secret"
require "duse/api/authorization/secret"

module Duse
  module API
    module V1
      module Actions
        module Secret
          Get = GetGenerator.new(self).build
        end
      end
    end
  end
end
