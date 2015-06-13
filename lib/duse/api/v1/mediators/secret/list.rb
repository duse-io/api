module Secret
  class List < Mediators::Base
    def call
      current_user.secrets
    end
  end
end

