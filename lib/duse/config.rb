module Duse
  module Config
    module SMTP
      module_function

      def enabled?
        !!host
      end

      def host
        ENV['SMTP_HOST']
      end

      def port
        ENV['SMTP_PORT']
      end

      def user
        ENV['SMTP_USER']
      end

      def password
        ENV['SMTP_PASSWORD']
      end

      def domain
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

