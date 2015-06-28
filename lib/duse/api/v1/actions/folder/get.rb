require 'duse/api/v1/actions/generator'
require 'duse/api/models/folder'
require 'duse/api/authorization/folder'

module Duse
  module API
    module V1
      module Actions
        module Folder
          Get = GetGenerator.new(self).build
        end
      end
    end
  end
end
