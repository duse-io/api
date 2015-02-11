module Duse
  module Config
    module_function

    def build
      config = OpenStruct.new
      config.secret_key = ENV['SECRET_KEY']
      config.host = ENV['HOST']
      config.email = ENV['EMAIL']

      config.smtp = OpenStruct.new
      config.smtp.enabled = !!ENV['SMTP_HOST']
      if config.smtp.enabled
        config.smtp.host = ENV['SMTP_HOST']
        config.smtp.port = ENV['SMTP_PORT']
        config.smtp.user = ENV['SMTP_USER']
        config.smtp.password = ENV['SMTP_PASSWORD']
        config.smtp.domain = ENV['SMTP_DOMAIN']
      end

      config
    end
  end
end

