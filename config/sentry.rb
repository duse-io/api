require 'duse/api'
require 'raven'

if Duse::API.config.use_sentry?
  Raven.configure do |config|
    config.dsn = Duse::API.config.sentry_dsn
  end
end

