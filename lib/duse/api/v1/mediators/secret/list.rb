require 'duse/api/v1/mediators/base'

module Duse
  module API
    module V1
      module Mediators
        module Secret
          class List < Mediators::Base
            def call
              current_user.secrets
            end
          end
        end
      end
    end
  end
end
