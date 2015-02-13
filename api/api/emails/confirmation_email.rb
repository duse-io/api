require 'duse'
require 'uri'
require 'duse/links'

class ConfirmationEmail
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def send
    mail = Mail.new do
      from    Duse.config.email
      subject 'Confirm your signup'
    end
    mail.to user.email
    mail.html_part = Mail::Part.new do
      content_type 'text/html; charset=UTF-8'
    end
    mail.html_part.body html_body

    mail.deliver!
  end

  private

  def html_body
    "Use the following command to confirm your account: duse account confirm --token #{create_confirmation_token}"
  end

  def create_confirmation_token
    raw_token, hash = Duse::Models::Token.generate_save_token
    token = Duse::Models::ConfirmationToken.create(token_hash: hash, user: user)
    raw_token
  end
end

