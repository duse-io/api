require 'duse/api/json_view'
require 'duse/api/v1/json_views/secret'

module Duse
  module API
    module V1
      module JSONViews
        class Folder < JSONView
          property :id, if: :not_nil
          property :name
          property :subfolders, as: Folder, type: :full
          property :secrets, as: Secret, render_type: :normal, type: :full
          property :url, if: ->(folder){ !folder.id.nil? } do |secret, options|
            "http://#{options[:host]}/v1/folders/#{secret.id}"
          end
        end
      end
    end
  end
end

