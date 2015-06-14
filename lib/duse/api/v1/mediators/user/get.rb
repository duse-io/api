module Duse
  module API
    module V1
      module Mediators
        module User
          class Get < Mediators::Base
            def call
              Models::User.find params[:id]
            rescue ActiveRecord::RecordNotFound
              raise NotFound
            end
          end
        end
      end
    end
  end
end
