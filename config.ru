#\ -s puma
require_relative 'config/environment'

if User.first(username: 'server').nil?
  user = User.create(username: 'server', password: 'rstnioerndordnior')
end

require 'api'
run API::API
