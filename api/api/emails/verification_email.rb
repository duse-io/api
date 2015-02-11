require 'duse'

class VerificationEmail
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def send
    mail = Mail.new do
      from    Duse.config.email
      subject 'Verify your signup'
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
    "<a href=\"#{verification_link}\">Click here to activate your Account</a>"
  end

  def verification_link
    ""
  end
end
