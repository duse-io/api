require 'rubygems'
require 'bundler'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
Bundler.require

require 'api'
run API::API
