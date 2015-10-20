require "uri"

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
        ssl == "true"
      end

      def protocol
        return "https" if ssl?
        "http"
      end

      def smtp
        host   = ENV["SMTP_HOST"] || "smtp.mandrillapp.com"
        port   = ENV["SMTP_PORT"] || "587"
        user   = ENV["SMTP_USER"] || ENV["MANDRILL_USERNAME"]
        pass   = ENV["SMTP_PASSWORD"] || ENV["MANDRILL_APIKEY"]
        domain = ENV["EMAIL"].nil? ? nil : ENV["EMAIL"].split("@").last

        @smtp ||= SMTP.new(
          host: host,
          port: port,
          user: user,
          password: pass,
          domain: domain
        )
      end
    end
  end
end

