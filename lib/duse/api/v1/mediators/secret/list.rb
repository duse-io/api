module Duse
  module API
    module V1
      module Mediators
        module Secret
          class List < Mediators::Base
            current_user.secrets
          end
        end
      end
    end
  end
end
