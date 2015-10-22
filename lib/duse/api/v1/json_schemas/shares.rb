require "duse/api/json_models"
require "duse/api/json_schema"
require "duse/api/validations/share"

module Duse
  module API
    module V1
      module JSONSchemas
        class Shares < DefaultJSON
          def initialize(json)
            super(json, Validations::Share, JSONSchema.new({
              type: Array,
              message: "Shares must be an array",
              items: {
                name: "Share",
                type: Hash,
                properties: {
                  id:   { name: "Share id", type: Integer },
                  content:   { type: String },
                  signature: { type: String }
                }
              }
            }))
          end
        end
      end
    end
  end
end

