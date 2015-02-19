require 'duse'
require 'raven'

Raven.configure do |config|
  config.dsn = Duse.config.sentry_dsn
end

