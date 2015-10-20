require "duse/api/v1/actions/user/get"

module Duse
  module API
    module V1
      module Actions
        module User
          class GetServer < User::Get
            def call
              Models::Server.get
            end
          end
        end
      end
    end
  end
end
