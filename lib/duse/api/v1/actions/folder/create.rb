require "duse/api/v1/json_schemas/folder"
require "duse/api/v1/json_views/folder"
require "duse/api/models/folder"

module Duse
  module API
    module V1
      module Actions
        module Folder
          class Create < Actions::Authenticated
            status 201
            validate_with JSONSchemas::Folder
            render JSONViews::Folder

            def call
              folder = Models::Folder.new({ user: current_user }.merge(sanitized_json))

              if !folder.save
                raise ValidationFailed, { message: folder.errors.full_messages }.to_json
              end
              folder
            end
          end
        end
      end
    end
  end
end
