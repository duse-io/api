require 'rubygems'
require 'bundler'

ENV['DATABASE_URL'] ||= 'postgres://duse_api:password1@localhost/duse_api_test'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'api'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
Bundler.require
