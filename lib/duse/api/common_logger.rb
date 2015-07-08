module Duse
  module API
    class CommonLogger < Sinatra::CommonLogger

      private

      def log(env, status, header, began_at)
        now = Time.now
        length = extract_content_length(header)

        msg = %{log_type=HTTP_LOG timestamp=%s ip=%s remote_user=%s http_method=%s route=%s%s http_version=%s response_code=%d length=%s response_time=%0.4f\n} % [
          now.strftime('%FT%T%:z'),
          env['HTTP_X_FORWARDED_FOR'] || env["REMOTE_ADDR"] || "-",
          env["REMOTE_USER"] || "-",
          env[Rack::REQUEST_METHOD],
          env[Rack::PATH_INFO],
          env[Rack::QUERY_STRING].empty? ? "" : "?"+env[Rack::QUERY_STRING],
          env['HTTP_VERSION'],
          status.to_s[0..3],
          length,
          now - began_at ]

        logger = Logger.new(StringIO.new) if ENV['RACK_ENV'] == 'test'
        logger ||= @logger || env['rack.errors']
        # Standard library logger doesn't support write but it supports << which actually
        # calls to write on the log device without formatting
        if logger.respond_to?(:write)
          logger.write(msg)
        else
          logger << msg
        end
      end
    end
  end
end

