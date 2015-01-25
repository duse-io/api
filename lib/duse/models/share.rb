module Duse
  module Models
    class Share < ActiveRecord::Base
      belongs_to :secret_part
      belongs_to :user
    end
  end
end
