module Duse
  module API
    module V1
      module Actions
        module User
          class GetServer < Actions::Base
            authenticate
            status 200
            render JSONViews::User, type: :full

            def call
              Models::Server.get
            end
          end
        end
      end
    end
  end
end
