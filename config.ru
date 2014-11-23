#\ -s puma
require_relative 'config/environment'

if User.first(username: 'server').nil?
  user = User.create(username: 'server', password: 'rstnioerndordnior', public_key: ENV['PUB_KEY'], private_key: ENV['PRIV_KEY'])
end

require 'api'
run API::API
