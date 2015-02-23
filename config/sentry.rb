require 'duse'
require 'raven'

if Duse.config.use_sentry?
  Raven.configure do |config|
    config.dsn = Duse.config.sentry_dsn
  end
end

