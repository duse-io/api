require 'duse/api/models/user'
require 'duse/api/models/secret'

module Duse
  module Models
    class UserSecret < ActiveRecord::Base
      belongs_to :user
      belongs_to :secret
    end
  end
end

