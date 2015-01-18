describe Duse::API do
  include Rack::Test::Methods

  def app
    Duse::API
  end

  def share(user_id, raw_share, private_key, public_key)
    encrypted_share, signature = Encryption.encrypt(
      private_key, public_key, raw_share
    )
    { user_id: user_id, content: encrypted_share, signature: signature }
  end

  def default_secret(options = {})
    user1_key = generate_key
    user1 = create_default_user(
      username: 'flower-pot', public_key: user1_key.public_key
    )
    user2_key = generate_key
    user2 = create_default_user(
      username: 'adracus', public_key: user2_key.public_key
    )

    {
      title: options[:title] || 'my secret',
      parts: [
        [
          share(Duse::Models::Server.get.id, 'share1', user1_key, Duse::Models::Server.public_key),
          share(user1.id, 'share2', user1_key, user1.public_key),
          share(user2.id, 'share3', user1_key, user2.public_key)
        ]
      ]
    }.to_json
  end

  def expect_count(entities)
    expect(Duse::Models::User.all.count).to eq(entities[:user])
    expect(Duse::Models::Secret.all.count).to eq(entities[:secret])
    expect(Duse::Models::SecretPart.all.count).to eq(entities[:secret_part])
    expect(Duse::Models::Share.all.count).to eq(entities[:share])
  end

  before :each do
    DatabaseCleaner.start
    Duse::Models::Server.ensure_user_exists
  end

  after :each do
    DatabaseCleaner.clean
  end

  # big integration test, testing usual workflow
  it 'persists a new secret correctly' do
    user1_key = generate_key
    user1 = create_default_user(
      username: 'flower-pot', public_key: user1_key.public_key
    )
    user2_key = generate_key
    user2 = create_default_user(
      username: 'adracus', public_key: user2_key.public_key
    )
    secret_json = {
      title: 'my secret',
      parts: [
        [
          share(Duse::Models::Server.get.id, 'share1', user1_key, Duse::Models::Server.public_key),
          share(user1.id, 'share2', user1_key, user1.public_key),
          share(user2.id, 'share3', user1_key, user2.public_key)
        ]
      ]
    }.to_json

    header 'Authorization', user1.api_token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(201)
    secret_id = Duse::Models::Secret.first.id
    expect(last_response.body).to eq({
      id: secret_id,
      title: 'my secret',
      url: "http://example.org/v1/secrets/#{secret_id}"
    }.to_json)
    expect_count(user: 3, secret: 1, secret_part: 1, share: 3)

    header 'Authorization', user1.api_token
    get "/v1/secrets/#{secret_id}"
    users = Duse::Models::User.all.map do |user|
      {
        'id' => user.id,
        'username' => user.username,
        'public_key' => user.public_key.to_s,
        'url' => "http://example.org/v1/users/#{user.id}"
      }
    end
    response = JSON.parse last_response.body
    response['shares'].map! do |part|
      part.map do |share|
        Encryption.decrypt user1_key, share
      end
    end
    expect(response).to eq({
      'id' => secret_id,
      'title' => 'my secret',
      'shares' => [%w(share1 share2)],
      'users' => users,
      'url' => "http://example.org/v1/secrets/#{secret_id}",
    })

    other_user = create_default_user
    header 'Authorization', other_user.api_token
    get "/v1/secrets/#{secret_id}"
    expect(last_response.status).to eq 403

    header 'Authorization', user1.api_token
    get '/v1/secrets'
    expect(last_response.body).to eq(
      [
        {
          id: secret_id,
          title: 'my secret',
          url: "http://example.org/v1/secrets/#{secret_id}",
        }
      ].to_json
    )

    header 'Authorization', user1.api_token
    user = Duse::Models::User.first
    get "/v1/users/#{user.id}"
    expect(last_response.body).to eq(
      {
        id: user.id,
        username: user.username,
        public_key: user.public_key.to_s,
        url: "http://example.org/v1/users/#{user.id}"
      }.to_json
    )

    header 'Authorization', user1.api_token
    delete "/v1/secrets/#{secret_id}"
    expect(last_response.status).to eq(204)
    expect(last_response.body).to eq('')

    expect_count(user: 4, secret: 0, secret_part: 0, share: 0)
  end

  it 'should return 404 for a non existant secret' do
    user = create_default_user

    header 'Authorization', user.api_token
    get '/v1/secrets/1', 'CONTENT_TYPE' => 'application/json'
    expect(last_response.status).to eq(404)
  end

  it 'should not try to do semantic validate when json validation fails' do
    user = create_default_user
    secret_json = { title: 'test', parts: 'test' }.to_json

    header 'Authorization', user.api_token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect_count(user: 2, secret: 0, secret_part: 0, share: 0)
  end

  it 'should error on malformed json' do
    user = create_default_user

    header 'Authorization', user.api_token
    post '/v1/secrets', '{ ', 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(400)
    expect_count(user: 2, secret: 0, secret_part: 0, share: 0)
  end

  it 'should error when title is empty' do
    secret_json = default_secret(title: '')

    header 'Authorization', Duse::Models::User.first(username: 'flower-pot').api_token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect(last_response.body).to eq(
      { 'message' => ['Title must not be blank'] }.to_json
    )
    expect_count(user: 3, secret: 0, secret_part: 0, share: 0)
  end

  it 'should error if the provided users don\'t exist' do
    server = Duse::Models::User.first(username: 'server')
    key = generate_key
    user = create_default_user(username: 'user123', public_key: key.public_key)
    # we're not creating user #3, which triggers this behaviour
    secret_json = {
      title: 'my secret',
      parts: [[
        share(Duse::Models::Server.get.id, '1-19810ad8', key, server.public_key),
        share(user.id, '2-2867e0bd', key, user.public_key),
        {
          user_id: 3,
          content: '3-374eb6a2',
          signature: Encryption.sign(key, '3-374eb6a2')
        }
      ]]
    }.to_json

    header 'Authorization', user.api_token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect_count(user: 2, secret: 0, secret_part: 0, share: 0)
  end

  it 'should error if there is no part for the server' do
    key1 = generate_key
    user1 = create_default_user(username: 'user1', public_key: key1.public_key)
    key2 = generate_key
    user2 = create_default_user(username: 'user2', public_key: key2.public_key)
    secret_json = {
      title: 'my secret',
      parts: [[
        share(user1.id, '2-2867e0bd', key1, user1.public_key),
        share(user2.id, '3-374eb6a2', key1, user1.public_key)
      ]]
    }.to_json

    header 'Authorization', user1.api_token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect_count(user: 3, secret: 0, secret_part: 0, share: 0)
  end

  it 'should error when not all parts have shares for the same users' do
    server_user = Duse::Models::User.first username: 'server'
    key1 = generate_key
    user1 = create_default_user(username: 'user1', public_key: key1.public_key)
    key2 = generate_key
    user2 = create_default_user(username: 'user2', public_key: key2.public_key)
    key3 = generate_key
    user3 = create_default_user(username: 'user3', public_key: key3.public_key)
    secret_json = {
      title: 'my secret',
      parts: [
        [
          share(server_user.id, '1-19810ad8', key1, server_user.public_key),
          share(user1.id, '2-2867e0bd', key1, user1.public_key),
          share(user2.id, '3-374eb6a2', key1, user2.public_key)
        ],
        [
          share(server_user.id, '1-940cc79',  key1, server_user.public_key),
          share(user2.id, '2-2867e0bd', key1, user2.public_key),
          share(user3.id, '3-374eb6a2', key1, user3.public_key)
        ]
      ]
    }.to_json

    header 'Authorization', user1.api_token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect_count(user: 4, secret: 0, secret_part: 0, share: 0)
  end

  it 'should error when at least one of the provided users do not exist' do
    server_user = Duse::Models::User.first username: 'server'
    key1 = generate_key
    user1 = create_default_user(username: 'user1', public_key: key1.public_key)
    secret_json = {
      title: 'my secret',
      parts: [
        [
          share(Duse::Models::Server.get.id, '1-19810ad8', key1, server_user.public_key),
          share(user1.id, '2-2867e0bd', key1, user1.public_key),
          share(3, '3-374eb6a2', key1, user1.public_key)
        ]
      ]
    }.to_json

    header 'Authorization', user1.api_token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect_count(user: 2, secret: 0, secret_part: 0, share: 0)
  end

  it 'should error with 401 if the user does not provide an auth header' do
    post '/v1/secrets',
         default_secret.to_json,
         'CONTENT_TYPE' => 'application/json'
    expect(last_response.status).to eq(401)
    expect_count(user: 3, secret: 0, secret_part: 0, share: 0)
  end

  it 'should be able to update the title of a secret' do
    user1_key = generate_key
    user1 = create_default_user(
      username: 'flower-pot', public_key: user1_key.public_key
    )
    user2_key = generate_key
    user2 = create_default_user(
      username: 'adracus', public_key: user2_key.public_key
    )
    secret_json = {
      title: 'my secret',
      parts: [
        [
          share(Duse::Models::Server.get.id, 'share1', user1_key, Duse::Models::Server.public_key),
          share(user1.id, 'share2', user1_key, user1.public_key),
          share(user2.id, 'share3', user1_key, user2.public_key)
        ]
      ]
    }.to_json

    header 'Authorization', user1.api_token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    new_secret_json = {
      title: 'new title',
      parts: [
        [
          share(Duse::Models::Server.get.id, 'new_share1', user1_key, Duse::Models::Server.public_key),
          share(user1.id, 'new_share2', user1_key, user1.public_key),
          share(user2.id, 'new_share3', user1_key, user2.public_key)
        ]
      ]
    }.to_json
    secret = JSON.parse(last_response.body)
    header 'Authorization', user1.api_token
    patch "/v1/secrets/#{secret['id']}",
          new_secret_json,
          'CONTENT_TYPE' => 'application/json'
    expect(last_response.status).to eq 200

    header 'Authorization', user1.api_token
    get "/v1/secrets/#{secret['id']}", 'CONTENT_TYPE' => 'application/json'

    expect(JSON.parse(last_response.body)['title']).to eq 'new title'
  end
end
