require 'duse/api/v1/actions/authenticated'

module Duse
  module API
    module V1
      module Actions
        module User
          class List < Actions::Authenticated
            status 200
            render JSONViews::User

            def call
              Models::User.all
            end
          end
        end
      end
    end
  end
end
