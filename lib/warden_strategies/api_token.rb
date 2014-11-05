class APITokenStrategy < ::Warden::Strategies::Base
  def valid?
    !api_token.blank?
  end

  def authenticate!
    user = User.first(api_token: api_token)
    if user.nil?
      fail! 'Unauthenticated'
    else
      success! user
    end
  end

  private

  def api_token
    request.env['HTTP_AUTHORIZATION']
  end
end

Warden::Strategies.add(:api_token, APITokenStrategy)
