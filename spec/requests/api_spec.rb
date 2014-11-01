require 'rack/test'
require 'json'

describe API do
  include Rack::Test::Methods

  def app
    API::API
  end

  it 'persists a new secret correctly' do
    server = User.create({username: 'server', api_key: 'test123'})
    adracus = User.create({username: 'adracus', api_key: 'test123'})
    flowerpot = User.create({username: 'flower-pot', api_key: 'test123'})
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

    expect(last_response.status).to eq(201)
    expect(User.all.count).to eq(3)
    expect(Secret.all.count).to eq(1)
    expect(SecretPart.all.count).to eq(4)
    expect(Share.all.count).to eq(12)
  end

  it 'should error when title is empty' do

  end

  it 'should only accept required >= 2' do

  end

  it 'should only accept split >= 1' do

  end

  it 'should only persist parts if the number of parts is >= required' do

  end

  it 'should error if the provided users don\'t exist' do

  end

  it 'should error if there is no part for the server' do

  end

  it 'should error when not all parts have shares for the same users' do

  end
end
