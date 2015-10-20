require "duse/api/json_models"
require "duse/api/json_schema"

module Duse
  module API
    module V1
      module JSONSchemas
        class Email < DefaultJSON
          def initialize(json)
            super(json, nil, JSONSchema.new({
              type: Hash,
              message: "Email must be an object",
              properties: {
                email: { type: String }
              }
            }))
          end
        end
      end
    end
  end
end

