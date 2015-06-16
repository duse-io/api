module Duse
  module API
    module V1
      module Mediators
        module User
          class GetServer < Mediators::Base
            def call
              Models::Server.get
            end
          end
        end
      end
    end
  end
end
