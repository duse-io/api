require 'rack/test'
require 'json'

describe API do
  include Rack::Test::Methods

  def app
    API::API
  end

  it 'persists a new secret correctly' do
    server = User.create({username: 'server'})
    adracus = User.create({username: 'adracus'})
    flowerpot = User.create({username: 'flower-pot'})
    users = [server, adracus, flowerpot]

    secret = {
      title: 'my secret',
      required: 2,
      split: 4,
      parts: [
        {"#{server.id}" => "1-19810ad8", "#{adracus.id}" => "2-2867e0bd", "#{flowerpot.id}" => "3-374eb6a2"},
        {"#{server.id}" => "1-940cc79",  "#{adracus.id}" => "2-e671f52",  "#{flowerpot.id}" => "3-138d722b"},
        {"#{server.id}" => "1-3e8f8a59", "#{adracus.id}" => "2-70f6da4d", "#{flowerpot.id}" => "3-235e2a42"},
        {"#{server.id}" => "1-117c3",    "#{adracus.id}" => "2-1f592",    "#{flowerpot.id}" => "3-d362"}
      ]
    }.to_json

    post '/v1/secrets', secret, 'CONTENT_TYPE' => 'application/json'

    p User.all
    p Secret.all
    p SecretPart.all
    p Share.all
  end
end
