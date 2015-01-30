module Duse
  module_function

  def secret_key
    ENV['SECRET_KEY']
  end
end

