module Duse
  module API
    module V1
      module Actions
        module User
          class Get < Actions::Base
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
