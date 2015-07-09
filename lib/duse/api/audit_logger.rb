module Duse
  module API
    class AuditLogger
      FORMAT = %{log_type=AUDIT_LOG timestamp=%s user_id=%s action=%s args=%s result=%s error=%s\n}

      def initialize
        @logger = Logger.new(ENV['RACK_ENV'] == 'test' ? StringIO.new : STDOUT)
      end

      def log(options)
        msg = FORMAT % [
          Time.now.strftime('%FT%T%:z'),
          user_id(options[:current_user]),
          options[:action],
          options[:action].arg_value_list(options[:args]),
          options[:result],
          error(options[:error])
        ]
        @logger << msg
      end

      def user_id(current_user)
        if_not_nil(current_user) { current_user.id }
      end

      def error(error)
        if_not_nil(error) { error.class }
      end

      def if_not_nil(subject, &block)
        return '-' if subject.nil?
        block.call
      end
    end
  end
end

