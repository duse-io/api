require 'duse/config'
require 'stringio'

module Duse
  module_function

  def config
    @config ||= Config.build
  end

  def logger=(logger)
    @logger = logger
  end

  def logger
    @logger
  end
end

