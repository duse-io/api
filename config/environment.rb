require 'rubygems'
require 'bundler'
require 'dotenv'
Dotenv.load

ENV['ENV'] ||= 'development'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'api'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
Bundler.require

require_relative 'database'

