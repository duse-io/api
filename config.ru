#\ -s puma
require_relative "config/environment"

require "duse/api"
Duse::API::Models::Server.ensure_user_exists
run Duse::API::App.new

