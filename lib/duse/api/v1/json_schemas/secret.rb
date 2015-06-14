require 'duse/api/json_models'
require 'duse/api/json_schema'
require 'duse/api/validations/secret_validator'

module Duse
  module API
    module V1
      module JSONSchemas
        class Secret < DefaultJSON
          def initialize(json)
            super(json, SecretValidator, JSONSchema.new({
              type: Hash,
              message: 'Secret must be an object',
              properties: {
                title: { type: String },
                cipher_text: { type: String },
                shares: {
                  type: Array,
                  allow_empty: false,
                  items: {
                    name: 'Share',
                    type: Hash,
                    properties: {
                      user_id:   { name: 'User id', type: Integer },
                      content:   { type: String },
                      signature: { type: String }
                    }
                  }
                }
              }
            }))
          end
        end
      end
    end
  end
end

