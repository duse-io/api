module Duse
  module API
    module V1
      module Actions
        module User
          class Get < Actions::Authenticated
            status 200
            render JSONViews::User, type: :full

            def call(user_id)
              Models::User.find user_id
            rescue ActiveRecord::RecordNotFound
              raise NotFound
            end
          end
        end
      end
    end
  end
end
