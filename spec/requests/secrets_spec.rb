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
          'server' => '1-19810ad8',
          "#{users[0].id}" => '2-2867e0bd',
          "#{users[1].id}" => '3-374eb6a2'
        },
        {
          'server' => '1-940cc79',
          "#{users[0].id}" => '2-e671f52',
          "#{users[1].id}" => '3-138d722b'
        },
        {
          'server' => '1-3e8f8a59',
          "#{users[0].id}" => '2-70f6da4d',
          "#{users[1].id}" => '3-235e2a42'
        },
        {
          'server' => '1-117c3',
          "#{users[0].id}" => '2-1f592',
          "#{users[1].id}" => '3-d362'
        }
      ]
    }
  end

  def create_users!(usernames = [])
    usernames += ['adracus', 'flower-pot']
    users = []
    usernames.each do |username|
      user = User.new(
        username: username,
        password: 'password'
      )
      user.save
      users << user
    end
    users
  end

  def expect_count(entities)
    expect(User.all.count).to eq(entities[:user])
    expect(Secret.all.count).to eq(entities[:secret])
    expect(SecretPart.all.count).to eq(entities[:secret_part])
    expect(Share.all.count).to eq(entities[:share])
  end

  before :each do
    DatabaseCleaner.start
    User.create(username: 'server', password: 'rstnioerndordnior')
  end

  after :each do
    DatabaseCleaner.clean
  end

  # big integration test, testing usual workflow
  it 'persists a new secret correctly' do
    secret_json = secret.to_json

    token = User.first(username: 'flower-pot').api_token
    header 'Authorization', token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(201)
    secret_id = Secret.first.id
    expect(last_response.body).to eq({
      id: secret_id,
      title: 'my secret',
      required: 2,
      split: 4,
      url: "http://example.org/v1/secrets/#{secret_id}",
      shares_url: "http://example.org/v1/secrets/#{secret_id}/shares"
    }.to_json)
    expect_count(user: 3, secret: 1, secret_part: 4, share: 12)

    header 'Authorization', token
    get "/v1/secrets/#{secret_id}"
    users = User.all.map do |user|
      {
        id: user.id,
        username: user.username,
        url: "http://example.org/v1/users/#{user.id}"
      }
    end
    expect(last_response.body).to eq({
      id: secret_id,
      title: 'my secret',
      required: 2,
      split: 4,
      users: users,
      url: "http://example.org/v1/secrets/#{secret_id}",
      shares_url: "http://example.org/v1/secrets/#{secret_id}/shares"
    }.to_json)

    header 'Authorization', User.first(username: 'adracus').api_token
    get "/v1/secrets/#{secret_id}/shares"
    result = [
      ['1-19810ad8', '2-2867e0bd'],
      ['1-940cc79',  '2-e671f52'],
      ['1-3e8f8a59', '2-70f6da4d'],
      ['1-117c3',    '2-1f592']
    ]
    expect(last_response.body).to eq(result.to_json)

    header 'Authorization', token
    get '/v1/secrets'
    expect(last_response.body).to eq(
      [
        {
          id: secret_id,
          title: 'my secret',
          required: 2,
          split: 4,
          url: "http://example.org/v1/secrets/#{secret_id}",
          shares_url: "http://example.org/v1/secrets/#{secret_id}/shares"
        }
      ].to_json
    )

    header 'Authorization', token
    user = User.first
    get "/v1/users/#{user.id}"
    expect(last_response.body).to eq(
      {
        id: user.id,
        username: user.username,
        url: "http://example.org/v1/users/#{user.id}"
      }.to_json
    )

    header 'Authorization', token
    delete "/v1/secrets/#{secret_id}"
    expect(last_response.status).to eq(204)
    expect(last_response.body).to eq('')

    expect_count(user: 3, secret: 0, secret_part: 0, share: 0)
  end

  it 'should error when title is empty' do
    secret_json = secret(title: '').to_json

    token = User.first(username: 'flower-pot').api_token
    header 'Authorization', token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect(last_response.body).to eq(
      { 'message' => ['Title must not be blank'] }.to_json
    )
    expect_count(user: 3, secret: 0, secret_part: 0, share: 0)
  end

  it 'should only accept required >= 2' do
    secret_json = secret(required: 1).to_json

    token = User.first(username: 'flower-pot').api_token
    header 'Authorization', token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect_count(user: 3, secret: 0, secret_part: 0, share: 0)
  end

  it 'should only accept split >= 1' do
    secret_json = secret(split: 0).to_json

    token = User.first(username: 'flower-pot').api_token
    header 'Authorization', token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect_count(user: 3, secret: 0, secret_part: 0, share: 0)
  end

  it 'should only persist parts if the number of parts is >= required' do
    secret_json = secret(required: 5).to_json

    token = User.first(username: 'flower-pot').api_token
    header 'Authorization', token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect_count(user: 3, secret: 0, secret_part: 0, share: 0)
  end

  it 'should error if the provided users don\'t exist' do
    user = User.new username: 'user123', password: 'password'
    user.save
    # we're not creating user #3, which triggers this behaviour
    parts = [
      { 'server' => '1-9810ad8', '2' => '2-867e0bd', '3' => '3-74eb6a2' },
      { 'server' => '1-40cc79',  '2' => '2-671f52',  '3' => '3-38d722b' },
      { 'server' => '1-e8f8a59', '2' => '2-0f6da4d', '3' => '3-35e2a42' },
      { 'server' => '1-17c3',    '2' => '2-f592',    '3' => '3-362' }
    ]
    secret_json = secret(users: [], parts: parts).to_json

    header 'Authorization', user.api_token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect_count(user: 2, secret: 0, secret_part: 0, share: 0)
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

    header 'Authorization', users[1].api_token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect_count(user: 4, secret: 0, secret_part: 0, share: 0)
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

    header 'Authorization', users[1].api_token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect_count(user: 4, secret: 0, secret_part: 0, share: 0)
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

    header 'Authorization', users[1].api_token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect_count(user: 3, secret: 0, secret_part: 0, share: 0)
  end

  it 'should error with 401 if the user does not provide an auth header' do
    post '/v1/secrets', secret.to_json, 'CONTENT_TYPE' => 'application/json'
    expect(last_response.status).to eq(401)
    expect_count(user: 3, secret: 0, secret_part: 0, share: 0)
  end
end
