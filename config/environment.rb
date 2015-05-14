require 'rubygems'
require 'bundler'
require 'bundler/setup'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
Bundler.require
require 'duse/api'

require_relative 'mail'
require_relative 'sentry'

