module Duse
  module Config
    module SMTP
      module_function

      def enabled?
        !!smtp_host
      end

      def smtp_host
        ENV['SMTP_HOST']
      end

      def smtp_port
        ENV['SMTP_PORT']
      end

      def smtp_user
        ENV['SMTP_USER']
      end

      def smtp_password
        ENV['SMTP_PASSWORD']
      end

      def smtp_domain
        ENV['SMTP_DOMAIN']
      end
    end

    module_function

    def secret_key
      ENV['SECRET_KEY']
    end

    def ssl
      ENV['SSL']
    end

    def ssl?
      ssl == 'true'
    end

    def protocol
      return 'https' if ssl?
      'http'
    end

    def host
      ENV['HOST']
    end

    def email
      ENV['EMAIL']
    end

    def smtp
      SMTP
    end
  end
end

