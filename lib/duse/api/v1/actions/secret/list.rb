require 'duse/api/v1/actions/base'

module Duse
  module API
    module V1
      module Actions
        module Secret
          class List < Actions::Base
            authenticate
            status 200
            render JSONViews::Secret

            def call
              current_user.secrets
            end
          end
        end
      end
    end
  end
end
