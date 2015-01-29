class TokenFacade
  def initialize(current_user)
    @current_user = current_user
  end

  def create!
    raw_token, token_hash = Duse::Models::Token.generate_save_token
    Duse::Models::Token.create token_hash: token_hash, user: @current_user
    raw_token
  end
end

