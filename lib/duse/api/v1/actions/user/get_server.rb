module Duse
  module API
    module V1
      module Actions
        module User
          class GetServer < Actions::Base
            def call
              Models::Server.get
            end
          end
        end
      end
    end
  end
end
