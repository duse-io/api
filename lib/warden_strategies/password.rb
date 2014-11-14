class PasswordStrategy < ::Warden::Strategies::Base
  def valid?
    params['username'] && params['password']
  end

  def authenticate!
    user = Model::User.first(username: params['username'])
    if !user.nil? && user.password == params['password']
      return success! user
    end
    fail! 'Username or password incorrect.'
  end
end

Warden::Strategies.add(:password, PasswordStrategy)
