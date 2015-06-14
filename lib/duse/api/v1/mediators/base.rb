module Duse
  module API
    module V1
      module Mediators
        class Base
          attr_reader :current_user, :params, :json

          def initialize(current_user, params, json)
            @current_user = current_user
            @params = params
            @json = json
          end
        end
      end
    end
  end
end
