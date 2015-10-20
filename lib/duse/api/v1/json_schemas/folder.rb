require "duse/api/json_models"
require "duse/api/validations/folder"

module Duse
  module API
    module V1
      module JSONSchemas
        class Folder < DefaultJSON
          def initialize(json)
            super(json, Validations::Folder, JSONSchema.new({
              type: Hash,
              message: "Folder must be an object",
              properties: {
                name: { type: String },
              }
            }))
          end
        end
      end
    end
  end
end

