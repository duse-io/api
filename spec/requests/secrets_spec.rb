describe API do
  include Rack::Test::Methods

  def app
    API::API
  end

  def share(raw_share, private_key, public_key)
    encrypted_share, signature = Encryption.encrypt(
      private_key, public_key, raw_share
    )
    { share: encrypted_share, signature: signature }
  end

  def secret(options = {})
    server_user = User.first username: 'server'
    users = options[:users]
    private_key = options[:private_key]
    raw_parts = options[:parts] || [
      ['1-19810ad8', '2-2867e0bd', '3-374eb6a2']
    ]

    parts = []
    raw_parts.each do |raw_part|
      shares = {}
      shares['server'] = share(raw_part[0], private_key, server_user.public_key)
      raw_part[1..raw_part.length-1].each_with_index do |raw_share, index|
        public_key = users[index].public_key
        shares["#{users[index].id}"] = share(raw_share, private_key, public_key)
      end
      parts << shares
    end

    {
      title: options[:title] || 'my secret',
      required: options[:required] || 2,
      parts: parts
    }
  end

  def default_secret(options = {})
    user1_key = generate_key
    user1 = User.create username: 'flower-pot', password: 'test', public_key: user1_key.public_key
    user2_key = generate_key
    user2 = User.create username: 'adracus', password: 'test', public_key: user2_key.public_key
    options.merge!({ users: [user1, user2], current_user: user1, private_key: user1_key })
    raw_secret = secret(options)
    [raw_secret, user1, user1_key, user2, user2_key]
  end

  def expect_count(entities)
    expect(User.all.count).to eq(entities[:user])
    expect(Secret.all.count).to eq(entities[:secret])
    expect(SecretPart.all.count).to eq(entities[:secret_part])
    expect(Share.all.count).to eq(entities[:share])
  end

  before :each do
    DatabaseCleaner.start
    key = generate_key
    User.create username: 'server', password: 'rstnioerndordnior', public_key: key.public_key, private_key: key.to_pem
  end

  after :each do
    DatabaseCleaner.clean
  end

  # big integration test, testing usual workflow
  it 'persists a new secret correctly' do
    raw_secret, user1, user1_key, user2, user2_key = default_secret
    secret_json = raw_secret.to_json

    token = user1.api_token
    header 'Authorization', token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(201)
    secret_id = Secret.first.id
    expect(last_response.body).to eq({
      id: secret_id,
      title: 'my secret',
      required: 2,
      url: "http://example.org/v1/secrets/#{secret_id}",
      shares_url: "http://example.org/v1/secrets/#{secret_id}/shares"
    }.to_json)
    expect_count(user: 3, secret: 1, secret_part: 1, share: 3)

    header 'Authorization', token
    get "/v1/secrets/#{secret_id}"
    users = User.all.map do |user|
      {
        id: user.id,
        username: user.username,
        public_key: user.public_key.to_s,
        url: "http://example.org/v1/users/#{user.id}"
      }
    end
    expect(last_response.body).to eq({
      id: secret_id,
      title: 'my secret',
      required: 2,
      users: users,
      url: "http://example.org/v1/secrets/#{secret_id}",
      shares_url: "http://example.org/v1/secrets/#{secret_id}/shares"
    }.to_json)

    header 'Authorization', User.first(username: 'adracus').api_token
    get "/v1/secrets/#{secret_id}/shares"
    expected_result = [
      ['1-19810ad8', '3-374eb6a2'],
    ]
    result = JSON.parse last_response.body
    result.map! do |part|
      part.map do |share|
        Encryption.decrypt user2_key, share
      end
    end
    expect(result).to eq(expected_result)

    header 'Authorization', token
    get '/v1/secrets'
    expect(last_response.body).to eq(
      [
        {
          id: secret_id,
          title: 'my secret',
          required: 2,
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
        public_key: user.public_key.to_s,
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
    raw_secret, user1, user1_key, user2, user2_key = default_secret(title: '')
    secret_json = raw_secret.to_json

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
    raw_secret, user1, user1_key, user2, user2_key = default_secret(required: 1)
    secret_json = raw_secret.to_json

    token = User.first(username: 'flower-pot').api_token
    header 'Authorization', token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect_count(user: 3, secret: 0, secret_part: 0, share: 0)
  end

  it 'should only persist parts if the number of parts is >= required' do
    raw_secret, user1, user1_key, user2, user2_key = default_secret(required: 5)
    secret_json = raw_secret.to_json

    token = User.first(username: 'flower-pot').api_token
    header 'Authorization', token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect_count(user: 3, secret: 0, secret_part: 0, share: 0)
  end

  it 'should error if the provided users don\'t exist' do
    server = User.first(username: 'server')
    key = generate_key
    user = User.create username: 'user123', password: 'password', public_key: key.public_key.to_s
    # we're not creating user #3, which triggers this behaviour
    secret_json = {
      title: 'my secret',
      required: 2,
      parts: [{
        'server'     => share('1-19810ad8', key, server.public_key),
        "#{user.id}" => share('2-2867e0bd', key, user.public_key),
        '3'          => { share: '3-374eb6a2', signature: Encryption.sign(key, '3-374eb6a2') }
      }]
    }.to_json

    header 'Authorization', user.api_token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect_count(user: 2, secret: 0, secret_part: 0, share: 0)
  end

  it 'should error if there is no part for the server' do
    key1 = generate_key
    user1 = User.create username: 'user1', password: 'password', public_key: key1.public_key.to_s
    key2 = generate_key
    user2 = User.create username: 'user2', password: 'password', public_key: key2.public_key.to_s
    secret_json = {
      title: 'my secret',
      required: 2,
      parts: [{
        "#{user1.id}" => share('2-2867e0bd', key1, user1.public_key),
        "#{user2.id}" => share('3-374eb6a2', key1, user1.public_key),
      }]
    }.to_json

    header 'Authorization', user1.api_token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect_count(user: 3, secret: 0, secret_part: 0, share: 0)
  end

  it 'should error when not all parts have shares for the same users' do
    server_user = User.first username: 'server'
    key1 = generate_key
    user1 = User.create username: 'user1', password: 'password', public_key: key1.public_key.to_s
    key2 = generate_key
    user2 = User.create username: 'user2', password: 'password', public_key: key2.public_key.to_s
    key3 = generate_key
    user3 = User.create username: 'user3', password: 'password', public_key: key3.public_key.to_s
    secret_json = {
      title: 'my secret',
      required: 2,
      parts: [
        {
          'server'      => share('1-19810ad8', key1, server_user.public_key),
          "#{user1.id}" => share('2-2867e0bd', key1, user1.public_key),
          "#{user2.id}" => share('3-374eb6a2', key1, user2.public_key)
        },
        {
          'server'      => share('1-940cc79',  key1, server_user.public_key),
          "#{user2.id}" => share('2-2867e0bd', key1, user2.public_key),
          "#{user3.id}" => share('3-374eb6a2', key1, user3.public_key)
        }
      ]
    }.to_json

    header 'Authorization', user1.api_token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect_count(user: 4, secret: 0, secret_part: 0, share: 0)
  end

  it 'should error when at least one of the provided users do not exist' do
    server_user = User.first username: 'server'
    key1 = generate_key
    user1 = User.create username: 'user1', password: 'password', public_key: key1.public_key
    secret_json = {
      title: 'my secret',
      required: 2,
      parts: [
        {
          'server'      => share('1-19810ad8', key1, server_user.public_key),
          "#{user1.id}" => share('2-2867e0bd', key1, user1.public_key),
          '3'           => share('3-374eb6a2', key1, user1.public_key)
        }
      ]
    }.to_json

    header 'Authorization', user1.api_token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect_count(user: 2, secret: 0, secret_part: 0, share: 0)
  end

  it 'should error with 401 if the user does not provide an auth header' do
    post '/v1/secrets', default_secret.to_json, 'CONTENT_TYPE' => 'application/json'
    expect(last_response.status).to eq(401)
    expect_count(user: 3, secret: 0, secret_part: 0, share: 0)
  end
end
