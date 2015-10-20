module Duse
  module API
    class AuditLogger
      FORMAT = %{log_type=AUDIT_LOG timestamp=%s user_id=%s action=%s args=%s result=%s error=%s\n}

      attr_reader :logger

      def initialize(logger)
        @logger = logger
      end

      def log(options)
        msg = FORMAT % [
          Time.now.strftime("%FT%T%:z"),
          user_id(options[:current_user]),
          options[:action],
          options[:action].arg_value_list(options[:args]),
          options[:result],
          error(options[:error])
        ]

        if logger.respond_to?(:write)
          logger.write(msg)
        else
          logger << msg
        end
      end

      def user_id(current_user)
        if_not_nil(current_user) { current_user.id }
      end

      def error(error)
        if_not_nil(error) { error.class }
      end

      def if_not_nil(subject, &block)
        return "-" if subject.nil?
        yield
      end
    end
  end
end

