class VersionSwitch
  AVAILABLE_VERSIONS = [1]
  DEFAULT_VERSION = 1
  ACCEPT_REGEX = /application\/vnd\.duse\.([#{AVAILABLE_VERSIONS.join}])\+json/

  def initialize(app)
    @app = app
  end

  def call(env)
    env['PATH_INFO'] = add_version_prefix(env['PATH_INFO'], env['ACCEPT'])
    @app.call(env)
  end

  def version_by_accept(accept_header)
    version = DEFAULT_VERSION
    matches = ACCEPT_REGEX.match(accept_header)
    unless matches.nil?
      version = matches[1]
    end
    version
  end

  def add_version_prefix(path, accept_header)
    version = version_by_accept(accept_header)
    version_path_prefix = "/v#{version}"
    path = File.join(version_path_prefix, path) if path[0..2] !~ /\/v[#{AVAILABLE_VERSIONS.join}]/
    ensure_no_trailing_slash path
  end

  def ensure_no_trailing_slash(path)
    if path[-1] == '/'
      return path[0..-2]
    end
    path
  end
end
