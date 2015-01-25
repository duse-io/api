module Duse
  module Models
    class Secret < ActiveRecord::Base
      has_many :secret_parts, dependent: :destroy
      has_many :shares, through: :secret_parts
      has_many :users,  through: :shares
      belongs_to :last_edited_by, class_name: 'User', foreign_key: :last_edited_by_id

      def secret_parts_for(user)
        secret_parts.order('index ASC').map do |part|
          part.raw_shares_from user
        end
      end
    end
  end
end
