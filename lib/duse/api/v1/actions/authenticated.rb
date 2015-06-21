require 'duse/api/v1/actions/base'

module Duse
  module API
    module V1
      module Actions
        class Authenticated < Base
          authenticate
        end
      end
    end
  end
end
