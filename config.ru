#\ -s puma
require_relative 'config/environment'

require 'api'
Duse::Models::Server.ensure_user_exists
run Duse::API

