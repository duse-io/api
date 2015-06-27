require 'rubygems'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'active_record'
require 'duse/api'

require_relative 'mail'
require_relative 'sentry'

