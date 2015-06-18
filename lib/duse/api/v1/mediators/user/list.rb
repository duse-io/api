require 'duse/api/v1/mediators/base'

module Duse
  module API
    module V1
      module Mediators
        module User
          class List < Mediators::Base
            def call
              Models::User.all
            end
          end
        end
      end
    end
  end
end
