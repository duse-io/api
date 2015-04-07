require 'duse/api/emails/html_email'
require 'forwardable'

class UserEmail
  extend Forwardable
  def_delegators :@mail, :send

  def initialize(user, subject, html_body)
    @mail = HtmlEmail.new(
      subject: subject,
      recipient: user.email,
      html_body: html_body
    )
  end
end

