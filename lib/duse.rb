require 'duse/config'
require 'stringio'

module Duse
  module_function

  def config
    @config ||= Config.new(
      sentry_dsn: ENV['SENTRY_DSN'],
      secret_key: ENV['SECRET_KEY'],
      ssl: ENV['SSL'],
      host: ENV['HOST'],
      email: ENV['EMAIL']
    )
  end

  def logger=(logger)
    @logger = logger
  end

  def logger
    @logger
  end
end

