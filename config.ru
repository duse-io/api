#\ -s puma
require_relative 'config/environment'

Duse::Models::Server.ensure_user_exists

require 'api'
run Rack::Cascade.new [Duse::API, Duse::Endpoints::Routes]

