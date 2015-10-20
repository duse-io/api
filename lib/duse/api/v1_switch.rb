module Duse
  module API
    class V1Switch
      attr_reader :prefix, :accept, :version_header

      def initialize(app, prefix = "/v1", accept = "application/vnd.duse.1+json", version_header = "HTTP_DUSE_API_VERSION")
        @app            = app
        @prefix         = prefix
        @accept         = accept
        @version_header = version_header
      end

      def call(env)
        add_version_prefix_if_required(env)
        @app.call(env)
      end

      def add_version_prefix_if_required(env)
        if match_accept?(env) || match_version_header?(env)
          path = ensure_no_trailing_slash File.join(prefix, env["PATH_INFO"])
          env["PATH_INFO"] = path
        end
      end

      def match_accept?(env)
        accept == env["HTTP_ACCEPT"]
      end

      def match_version_header?(env)
        "1" == env[version_header]
      end

      def ensure_no_trailing_slash(path)
        Pathname.new(path).cleanpath.to_s
      end
    end
  end
end

