require 'duse/config'
require 'stringio'

module Duse
  module_function

  def config
    Config
  end

  def logger=(logger)
    @logger = logger
  end

  def logger
    @logger
  end
end

