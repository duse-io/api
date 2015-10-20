require "duse/api/json_models"
require "duse/api/json_schema"

module Duse
  module API
    module V1
      module JSONSchemas
        class Password < DefaultJSON
          def initialize(json)
            super(json, nil, JSONSchema.new({
              type: Hash,
              message: "Password reset must be an object",
              properties: {
                token: { type: String },
                password: { type: String }
              }
            }))
          end
        end
      end
    end
  end
end

