require 'duse/api/v1/actions/generator'
require 'duse/api/authorization/folder'

module Duse
  module API
    module V1
      module Actions
        module Folder
          Delete = DeleteGenerator.new(self).build
        end
      end
    end
  end
end
