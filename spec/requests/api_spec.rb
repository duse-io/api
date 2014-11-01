require 'rack/test'
require 'json'

describe API do
  include Rack::Test::Methods

  def app
    API::API
  end

  def secret(options = {})
    {
      title: options[:title] || 'my secret',
      required: options[:required] || 2,
      split: options[:split] || 4,
      parts: options[:parts] || [
        {"#{1}" => "1-19810ad8", "#{2}" => "2-2867e0bd", "#{3}" => "3-374eb6a2"},
        {"#{1}" => "1-940cc79",  "#{2}" => "2-e671f52",  "#{3}" => "3-138d722b"},
        {"#{1}" => "1-3e8f8a59", "#{2}" => "2-70f6da4d", "#{3}" => "3-235e2a42"},
        {"#{1}" => "1-117c3",    "#{2}" => "2-1f592",    "#{3}" => "3-d362"}
      ]
    }
  end

  def create_users!
    server = User.create({username: 'server', api_key: 'test123'})
    adracus = User.create({username: 'adracus', api_key: 'test123'})
    flowerpot = User.create({username: 'flower-pot', api_key: 'test123'})
    [server, adracus, flowerpot]
  end

  it 'persists a new secret correctly' do
    users = create_users!
    secret_json = secret.to_json

    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(201)
    expect(User.all.count).to eq(3)
    expect(Secret.all.count).to eq(1)
    expect(SecretPart.all.count).to eq(4)
    expect(Share.all.count).to eq(12)
  end

  it 'should error when title is empty' do
    secret_json = secret(title: '').to_json

    post '/v1/secrets', secret.to_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect(User.all.count).to eq(0)
    expect(Secret.all.count).to eq(0)
    expect(SecretPart.all.count).to eq(0)
    expect(Share.all.count).to eq(0)
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
