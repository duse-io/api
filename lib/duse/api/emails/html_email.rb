require "duse/api"
require "mail"

class HtmlEmail
  def initialize(options)
    @mail = Mail.new
    @mail.from Duse::API.config.email
    @mail.subject options[:subject]
    @mail.to options[:recipient]
    @mail.html_part = Mail::Part.new
    @mail.html_part.content_type "text/html; charset=UTF-8"
    @mail.html_part.body options[:html_body]
    @mail
  end

  def send
    @mail.deliver!
  end
end

