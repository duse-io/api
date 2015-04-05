require 'rubygems'
require 'bundler'
require 'bundler/setup'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'api'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
Bundler.require

require_relative 'mail'
require_relative 'sentry'

require 'sinatra/base'
require 'sinatra/namespace'
require 'sinatra/json'
require 'sinatra/activerecord'
require 'raven'

