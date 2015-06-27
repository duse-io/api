require 'duse/api/authorization/user'
require 'duse/api/v1/actions/generator'

module Duse
  module API
    module V1
      module Actions
        module User
          Delete = DeleteGenerator.new(self).build
        end
      end
    end
  end
end
