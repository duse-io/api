require 'duse/api/v1/actions/base'

module Duse
  module API
    module V1
      module Actions
        module User
          class List < Actions::Base
            def call
              Models::User.all
            end
          end
        end
      end
    end
  end
end
