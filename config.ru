#\ -s puma
require_relative 'config/environment'

Server.get

require 'api'
run API::API
