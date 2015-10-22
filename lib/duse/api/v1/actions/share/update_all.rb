require "duse/api/v1/json_schemas/shares"
require "duse/api/v1/json_views/share"
require "duse/api/models/share"
require "duse/api/authorization/share"

module Duse
  module API
    module V1
      module Actions
        module Share
          class UpdateAll < Actions::Authenticated
            status 204
            validate_with JSONSchemas::Shares

            def call
              ActiveRecord::Base.transaction do
                shares = sanitized_json.each do |share_json|
                  share = Models::Share.find(share_json[:id])
                  share.update(share_json.merge(last_edited_by: current_user))
                end
              end
            end
          end
        end
      end
    end
  end
end
