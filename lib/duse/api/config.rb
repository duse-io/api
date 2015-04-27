require 'uri'

module Duse
  module API
    class Config
      class SMTP
        include ActiveModel::Model

        attr_accessor :host, :port, :user, :password, :domain

        validates_presence_of :host, :port, :user, :password, :domain, if: :enabled?

        def enabled?
          !!host
        end
      end

      include ActiveModel::Model

      attr_accessor :sentry_dsn, :secret_key, :ssl, :host, :email

      validates_presence_of :secret_key, :host, :email

      def use_sentry?
        !!sentry_dsn
      end

      def ssl?
        ssl == 'true'
      end

      def protocol
        return 'https' if ssl?
        'http'
      end

      def smtp
        @smtp ||= SMTP.new(
          host: ENV['SMTP_HOST'],
          port: ENV['SMTP_PORT'],
          user: ENV['SMTP_USER'],
          password: ENV['SMTP_PASSWORD'],
          domain: ENV['EMAIL'].split('@').last
        )
      end
    end
  end
end

