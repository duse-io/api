require 'mail'

Mail.defaults do
  delivery_method :sendmail
end

if Duse::API.config.smtp.enabled?
  Mail.defaults do
    delivery_method :smtp, {
      port: Duse::API.config.smtp.port,
      address: Duse::API.config.smtp.host,
      user_name: Duse::API.config.smtp.user,
      password: Duse::API.config.smtp.password,
      domain: Duse::API.config.smtp.domain,
      authentication: 'plain'
    }
  end
end

