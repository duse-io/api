require 'duse/api/json_models'
require 'duse/api/validations/user'

module Duse
  module API
    module V1
      module JSONSchemas
        class User < DefaultJSON
          def initialize(json)
            super(json, Validations::User, JSONSchema.new({
              type: Hash,
              message: 'User must be an object',
              properties: {
                username:   { type: String },
                email:      { type: String },
                password:   { type: String },
                public_key: { type: String, name: 'Public key' }
              }
            }))
          end
        end
      end
    end
  end
end

