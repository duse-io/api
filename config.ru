#\ -s puma
require_relative 'config/environment'

if User.first(username: 'server').nil?
  password = ENV['PASSWORD']
  pub_key = ENV['PUB_KEY']
  priv_key = ENV['PRIV_KEY']
  User.create(username: 'server', password: password, password_confirmation: password, public_key: pub_key, private_key: priv_key)
end

require 'api'
run API::API
