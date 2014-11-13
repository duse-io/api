require 'rack/test'
require 'json'

describe API do
  include Rack::Test::Methods

  def app
    API::API
  end

  def secret(options = {})
    options[:users] ||= create_users!
    users = options[:users]

    {
      title: options[:title] || 'my secret',
      required: options[:required] || 2,
      split: options[:split] || 4,
      parts: options[:parts] || [
        {
          "server" => '1-19810ad8',
          "#{users[0].id}" => '2-2867e0bd',
          "#{users[1].id}" => '3-374eb6a2'
        },
        {
          "server" => '1-940cc79',
          "#{users[0].id}" => '2-e671f52',
          "#{users[1].id}" => '3-138d722b'
        },
        {
          "server" => '1-3e8f8a59',
          "#{users[0].id}" => '2-70f6da4d',
          "#{users[1].id}" => '3-235e2a42'
        },
        {
          "server" => '1-117c3',
          "#{users[0].id}" => '2-1f592',
          "#{users[1].id}" => '3-d362'
        }
      ]
    }
  end

  def create_users!(usernames = [])
    usernames += ['adracus', 'flower-pot']
    users = []
    usernames.each_with_index do |username, index|
      user = Model::User.new(
        username: username,
        password: 'password',
        api_token: "test#{index}"
      )
      p user.errors unless user.valid?
      user.save
      users << user
    end
    users
  end

  before :each do
    DatabaseCleaner.start
    Model::User.create(username: 'server', api_token: 'irsndnafdnwfndnw', password: 'rstnioerndordnior')
  end

  after :each do
    DatabaseCleaner.clean
  end

  # big integration test, testing usual workflow
  it 'persists a new secret correctly' do
    secret_json = secret.to_json

    header 'Authorization', 'test1'
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(201)
    expect(last_response.body).to eq({
      id: Model::Secret.first.id,
      title: 'my secret',
      required: 2,
      split: 4,
      url: "http://example.org/v1/secrets/#{Model::Secret.first.id}",
      shares_url: "http://example.org/v1/secrets/#{Model::Secret.first.id}/shares"
    }.to_json)
    expect(Model::User.all.count).to eq(3)
    expect(Model::Secret.all.count).to eq(1)
    expect(Model::SecretPart.all.count).to eq(4)
    expect(Model::Share.all.count).to eq(12)

    header 'Authorization', 'test1'
    get "/v1/secrets/#{Model::Secret.first.id}"
    users = Model::User.all.map do |user|
      {
        id: user.id,
        username: user.username,
        url: "http://example.org/v1/users/#{user.id}"
      }
    end
    expect(last_response.body).to eq({
      id: Model::Secret.first.id,
      title: 'my secret',
      required: 2,
      split: 4,
      users: users,
      url: "http://example.org/v1/secrets/#{Model::Secret.first.id}",
      shares_url: "http://example.org/v1/secrets/#{Model::Secret.first.id}/shares"
    }.to_json)

    header 'Authorization', 'test0'
    get "/v1/secrets/#{Model::Secret.first.id}/shares"
    result = [
      ['1-19810ad8', '2-2867e0bd'],
      ['1-940cc79',  '2-e671f52'],
      ['1-3e8f8a59', '2-70f6da4d'],
      ['1-117c3',    '2-1f592']
    ]
    expect(last_response.body).to eq(result.to_json)

    header 'Authorization', 'test1'
    get '/v1/secrets'
    expect(last_response.body).to eq(
      [
        {
          id: Model::Secret.first.id,
          title: 'my secret',
          required: 2,
          split: 4,
          url: "http://example.org/v1/secrets/#{Model::Secret.first.id}",
          shares_url: "http://example.org/v1/secrets/#{Model::Secret.first.id}/shares"
        }
      ].to_json
    )

    header 'Authorization', 'test1'
    user = Model::User.first
    get "/v1/users/#{user.id}"
    expect(last_response.body).to eq(
      {
        id: user.id,
        username: user.username,
        url: "http://example.org/v1/users/#{user.id}"
      }.to_json
    )

    header 'Authorization', 'test1'
    delete "/v1/secrets/#{Model::Secret.first.id}"
    expect(last_response.status).to eq(204)
    expect(last_response.body).to eq('')

    expect(Model::Secret.all.count).to eq(0)
    expect(Model::SecretPart.all.count).to eq(0)
    expect(Model::Share.all.count).to eq(0)
  end

  it 'should error when title is empty' do
    secret_json = secret(title: '').to_json

    header 'Authorization', 'test1'
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect(
      JSON.parse(last_response.body)['message'].include?(
        'Title must not be blank'
      )
    ).to be_truthy
    expect(Model::User.all.count).to eq(3)
    expect(Model::Secret.all.count).to eq(0)
    expect(Model::SecretPart.all.count).to eq(0)
    expect(Model::Share.all.count).to eq(0)
  end

  it 'should only accept required >= 2' do
    secret_json = secret(required: 1).to_json

    header 'Authorization', 'test1'
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect(Model::User.all.count).to eq(3)
    expect(Model::Secret.all.count).to eq(0)
    expect(Model::SecretPart.all.count).to eq(0)
    expect(Model::Share.all.count).to eq(0)
  end

  it 'should only accept split >= 1' do
    secret_json = secret(split: 0).to_json

    header 'Authorization', 'test1'
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect(Model::User.all.count).to eq(3)
    expect(Model::Secret.all.count).to eq(0)
    expect(Model::SecretPart.all.count).to eq(0)
    expect(Model::Share.all.count).to eq(0)
  end

  it 'should only persist parts if the number of parts is >= required' do
    secret_json = secret(required: 5).to_json

    header 'Authorization', 'test1'
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect(Model::User.all.count).to eq(3)
    expect(Model::Secret.all.count).to eq(0)
    expect(Model::SecretPart.all.count).to eq(0)
    expect(Model::Share.all.count).to eq(0)
  end

  it 'should error if the provided users don\'t exist' do
    user = Model::User.create(username: 'user123', api_token: 'test1', password: 'password')
    # we're not creating user #3, which trigger this behaviour
    parts = [
      { "server" => '1-9810ad8', '2' => '2-867e0bd', '3' => '3-74eb6a2' },
      { "server" => '1-40cc79',  '2' => '2-671f52',  '3' => '3-38d722b' },
      { "server" => '1-e8f8a59', '2' => '2-0f6da4d', '3' => '3-35e2a42' },
      { "server" => '1-17c3',    '2' => '2-f592',    '3' => '3-362' }
    ]
    secret_json = secret(users: [], parts: parts).to_json

    header 'Authorization', 'test1'
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect(Model::User.all.count).to eq(2)
    expect(Model::Secret.all.count).to eq(0)
    expect(Model::SecretPart.all.count).to eq(0)
    expect(Model::Share.all.count).to eq(0)
  end

  it 'should error if there is no part for the server' do
    users = create_users!(['testuser'])
    parts = [
      { '4' => '1-19810ad8', '2' => '2-2867e0bd', '3' => '3-374eb6a2' },
      { '4' => '1-940cc79',  '2' => '2-e671f52',  '3' => '3-138d722b' },
      { '4' => '1-3e8f8a59', '2' => '2-70f6da4d', '3' => '3-235e2a42' },
      { '4' => '1-117c3',    '2' => '2-1f592',    '3' => '3-d362' }
    ]
    secret_json = secret(parts: parts, users: users).to_json

    header 'Authorization', 'test1'
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect(Model::User.all.count).to eq(4)
    expect(Model::Secret.all.count).to eq(0)
    expect(Model::SecretPart.all.count).to eq(0)
    expect(Model::Share.all.count).to eq(0)
  end

  it 'should error when not all parts have shares for the same users' do
    users = create_users!(['testuser'])
    parts = [
      { '4' => '1-19810ad8', '2' => '2-2867e0bd', '3' => '3-374eb6a2' },
      { '1' => '1-940cc79',  '2' => '2-e671f52',  '3' => '3-138d722b' },
      { '1' => '1-3e8f8a59', '2' => '2-70f6da4d', '3' => '3-235e2a42' },
      { '1' => '1-117c3',    '2' => '2-1f592',    '3' => '3-d362' }
    ]
    secret_json = secret(parts: parts, users: users).to_json

    header 'Authorization', 'test1'
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect(Model::User.all.count).to eq(4)
    expect(Model::Secret.all.count).to eq(0)
    expect(Model::SecretPart.all.count).to eq(0)
    expect(Model::Share.all.count).to eq(0)
  end

  it 'should error when at least one of the provided users do not exist' do
    users = create_users!
    parts = [
      { '4' => '1-19810ad8', '2' => '2-2867e0bd', '3' => '3-374eb6a2' },
      { '1' => '1-940cc79',  '2' => '2-e671f52',  '3' => '3-138d722b' },
      { '1' => '1-3e8f8a59', '2' => '2-70f6da4d', '3' => '3-235e2a42' },
      { '1' => '1-117c3',    '2' => '2-1f592',    '3' => '3-d362' }
    ]
    secret_json = secret(parts: parts, users: users).to_json

    header 'Authorization', 'test1'
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect(Model::User.all.count).to eq(3)
    expect(Model::Secret.all.count).to eq(0)
    expect(Model::SecretPart.all.count).to eq(0)
    expect(Model::Share.all.count).to eq(0)
  end

  it 'should error with 401 if the user does not provide an auth header' do
    post '/v1/secrets', secret.to_json, 'CONTENT_TYPE' => 'application/json'
    expect(last_response.status).to eq(401)
    expect(Model::Secret.all.count).to eq(0)
    expect(Model::SecretPart.all.count).to eq(0)
    expect(Model::Share.all.count).to eq(0)
  end

  it 'should not error when listing a users secret but a users has none' do
    Model::User.create(username: 'test', api_token: 'test123', password: 'password')

    header 'Authorization', 'test123'
    get '/v1/secrets'

    expect(JSON.parse(last_response.body)).to eq([])
  end

  it 'should error with 404 when a users for a secret that does not exist are requested' do
    Model::User.create(username: 'test', api_token: 'test123', password: 'password')

    header 'Authorization', 'test123'
    get '/v1/secrets/1/users'

    expect(last_response.status).to eq(404)
  end

  it 'should error with 404 when retrieving shares for a not existing secret' do
    Model::User.create(username: 'test', api_token: 'test123', password: 'password')

    header 'Authorization', 'test123'
    get '/v1/secrets/1/shares'

    expect(last_response.status).to eq(404)
  end

  it 'should error with 404 when retrieving shares for a not existing secret' do
    Model::User.create(username: 'test', api_token: 'test123', password: 'password')

    header 'Authorization', 'test123'
    get '/v1/users/2'

    expect(last_response.status).to eq(404)
  end

  it 'should error with 404 when deleting a not existing secret' do
    Model::User.create(username: 'test', api_token: 'test123', password: 'password')

    header 'Authorization', 'test123'
    delete '/v1/secrets/1'

    expect(last_response.status).to eq(404)
  end

  it 'should persist the user correctly' do
    user_json = { username: 'test', api_token: 'test1', password: 'password' }.to_json
    post '/v1/users', user_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(201)
    expect(last_response.body).to eq(
      {
        id: Model::User.first(username: 'test').id,
        username: 'test',
        url: "http://example.org/v1/users/#{Model::User.first(username: 'test').id}"
      }.to_json
    )
    expect(Model::User.all.count).to eq(2)
  end

  it 'should error when a username is not given' do
    user_json = { api_token: 'test1' }.to_json
    post '/v1/users', user_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect(Model::User.all.count).to eq(1)
  end

  it 'should not put the api token in the json response' do
    user = Model::User.create username: 'test', api_token: 'test1', password: 'password'

    header 'Authorization', 'test1'
    get "/v1/users/#{user.id}", 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(200)
    expect(JSON.parse(last_response.body).key? 'api_token').to eq(false)
  end

  it 'should respond to listing users correctly' do
    user = Model::User.create username: 'test', api_token: 'test1', password: 'password'

    header 'Authorization', 'test1'
    get '/v1/users', 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq(
      [{
        id: Model::User.first('server').id,
        username: Model::User.first('server').username,
        url: "http://example.org/v1/users/#{Model::User.first('server').id}"
      },
      {
        id: user.id,
        username: user.username,
        url: "http://example.org/v1/users/#{user.id}"
      }].to_json
    )
  end
end
