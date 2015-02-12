require 'duse'
require 'mail'

Mail.defaults do
  delivery_method :sendmail
end

if Duse.config.smtp.enabled?
  Mail.defaults do
    delivery_method :smtp, {
      port: Duse.config.smtp.port,
      address: Duse.config.smtp.host,
      user_name: Duse.config.smtp.user,
      password: Duse.config.smtp.password,
      domain: Duse.config.smtp.domain,
      authentication: 'plain'
    }
  end
end

