describe API do
  include Rack::Test::Methods

  def app
    API::API
  end

  before :each do
    DatabaseCleaner.start
  end

  after :each do
    DatabaseCleaner.clean
  end

  it 'should persist the user correctly' do
    user_json = {
      username: 'flower-pot',
      password: 'Passw0rd!',
      password_confirmation: 'Passw0rd!',
      public_key: "-----BEGIN PUBLIC KEY-----\n" \
      "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDR1pYkhBVekZZvcgRaMR6iZTJt\n" \
      "fr6ALzIg1MHkkWonMXIJ5qvN+3Xeucf8Wk6c8I01T2PviQtnw/h+NjkBcvTKi/3y\n" \
      "2eMatpsu1QK5iaarWx25RcfFCkcElBZ8FibMfC2/DH+11kKIjlQN3iZaC3qd2Mpq\n" \
      "a042HsjIOuVQqTb/mQIDAQAB\n" \
      "-----END PUBLIC KEY-----\n"
    }.to_json
    post '/v1/users', user_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(201)
    user_id = User.first(username: 'flower-pot').id
    expect(last_response.body).to eq(
      {
        id: user_id,
        username: 'flower-pot',
        public_key: "-----BEGIN PUBLIC KEY-----\n" \
        "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDR1pYkhBVekZZvcgRaMR6iZTJt\n" \
        "fr6ALzIg1MHkkWonMXIJ5qvN+3Xeucf8Wk6c8I01T2PviQtnw/h+NjkBcvTKi/3y\n" \
        "2eMatpsu1QK5iaarWx25RcfFCkcElBZ8FibMfC2/DH+11kKIjlQN3iZaC3qd2Mpq\n" \
        "a042HsjIOuVQqTb/mQIDAQAB\n" \
        "-----END PUBLIC KEY-----\n",
        url: "http://example.org/v1/users/#{user_id}"
      }.to_json
    )
    expect(User.all.count).to eq(1)
  end

  it 'should error when a username is not given' do
    user_json = {
      password: 'Passw0rd!',
      password_confirmation: 'Passw0rd!',
      public_key: generate_public_key
    }.to_json
    post '/v1/users', user_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect(last_response.body).to eq({
      'message' => ['Username must not be blank']
    }.to_json)
    expect(User.all.count).to eq(0)
  end

  it 'should error when a username contains illegal characters' do
    user_json = {
      username: 'test?',
      password: 'Passw0rd!',
      password_confirmation: 'Passw0rd!',
      public_key: generate_public_key
    }.to_json
    post '/v1/users', user_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect(last_response.body).to eq({
      'message' => ['Username must be only letters, numbers, "-" and "_"']
    }.to_json)
    expect(User.all.count).to eq(0)
  end

  it 'should correctly handle non rsa public keys' do
    user_json = {
      username: 'test',
      password: 'Passw0rd!',
      password_confirmation: 'Passw0rd!',
      public_key: 'non rsa public key'
    }.to_json
    post '/v1/users', user_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect(last_response.body).to eq({
      'message' => ['Public key is not a valid RSA Public Key.']
    }.to_json)
    expect(User.all.count).to eq(0)
  end

  it 'should correctly handle no rsa public key' do
    user_json = {
      username: 'test',
      password: 'Passw0rd!',
      password_confirmation: 'Passw0rd!'
    }.to_json
    post '/v1/users', user_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect(last_response.body).to eq({
      'message' => ['Public key must not be blank']
    }.to_json)
    expect(User.all.count).to eq(0)
  end

  it 'should not validate further than blanks when nothing is given' do
    post '/v1/users', '{}', 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect(last_response.body).to eq({
      'message' => [
        'Username must not be blank',
        'Password must not be blank',
        'Password confirmation must not be blank',
        'Public key must not be blank'
      ]
    }.to_json)
    expect(User.all.count).to eq(0)
  end

  it 'should not put the api token in the json response' do
    user = create_default_user

    header 'Authorization', user.api_token
    get "/v1/users/#{user.id}", 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(200)
    expect(JSON.parse(last_response.body).key? 'api_token').to eq(false)
  end

  it 'should respond to listing users correctly' do
    user = create_default_user

    header 'Authorization', user.api_token
    get '/v1/users', 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq(
      [{
        id: user.id,
        username: 'test',
        url: "http://example.org/v1/users/#{user.id}"
      }].to_json
    )
  end

  it 'should return the users api token correctly' do
    user = create_default_user(username: 'test', password: 'Passw0rd!')

    post '/v1/users/token', {
      username: 'test',
      password: 'Passw0rd!'
    }.to_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq(
      { 'api_token' => user.api_token }.to_json
    )
  end

  it 'should return unauthenticated on wrong username or password' do
    create_default_user(username: 'test')

    post '/v1/users/token', {
      username: 'test',
      password: 'wrong-password'
    }.to_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(401)

    post '/v1/users/token', {
      username: 'wrong-username',
      password: 'some-password'
    }.to_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(401)
  end

  it 'should return the correct user when request own profile' do
    public_key = generate_public_key
    user = create_default_user(public_key: public_key)

    header 'Authorization', user.api_token
    get '/v1/users/me', 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq({
      id: user.id,
      username: 'test',
      public_key: public_key,
      url: "http://example.org/v1/users/#{user.id}"
    }.to_json)
  end

  it 'should return the correct user when requesting the server user' do
    user = create_default_user
    server_user = Server.get

    header 'Authorization', user.api_token
    get '/v1/users/server', 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq({
      id: server_user.id,
      username: 'server',
      public_key: server_user.public_key.to_s,
      url: "http://example.org/v1/users/#{server_user.id}"
    }.to_json)
  end

  it 'should return the new token when requesting a new one' do
    user = create_default_user

    header 'Authorization', user.api_token
    post '/v1/users/token/regenerate', 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(201)
    expect(last_response.body).not_to eq({
      api_token: user.api_token # this is still the old token before refreshing
    }.to_json)
    expect(last_response.body).to eq({
      api_token: User.get(user.id).api_token
    }.to_json)
  end
end
