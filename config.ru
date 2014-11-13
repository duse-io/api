require_relative 'config/environment'

if Model::User.first(username: 'server').nil?
  user = Model::User.create(username: 'server', api_token: 'irsndnafdnwfndnw', password: 'rstnioerndordnior')
end

require 'api'
run API::API
