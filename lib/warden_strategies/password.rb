class PasswordStrategy < ::Warden::Strategies::Base
  def valid?
    params['username'] && params['password']
  end

  def authenticate!
    user = User.first(username: params['username'])
    return success! user if !user.nil? && user.password == params['password']
    fail! 'Username or password incorrect.'
  end
end

Warden::Strategies.add(:password, PasswordStrategy)
