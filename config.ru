#\ -s puma
require_relative 'config/environment'

Duse::Models::Server.ensure_user_exists

require 'api'
run Duse::API

