module Duse
  class PasswordStrategy < ::Warden::Strategies::Base
    def valid?
      params['username'] && params['password']
    end

    def authenticate!
      user = Duse::Models::User.find_by_username params['username']
      if !user.nil? && user.try(:authenticate, params['password'])
        return success! user
      end
      fail! 'Username or password incorrect.'
    end
  end
end

Warden::Strategies.add(:password, Duse::PasswordStrategy)

