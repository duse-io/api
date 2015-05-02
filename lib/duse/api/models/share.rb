module Duse
  module Models
    class Share < ActiveRecord::Base
      belongs_to :secret
      belongs_to :user
    end
  end
end

