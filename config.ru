#\ -s puma
require_relative 'config/environment'

Server.ensure_user_exists

require 'api'
run API::API
