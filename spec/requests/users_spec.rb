describe Duse::API do
  include Rack::Test::Methods

  def app
    Duse::API
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
    user_id = Duse::Models::User.find_by_username('flower-pot').id
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
    expect(Duse::Models::User.all.count).to eq(1)
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
    expect(Duse::Models::User.all.count).to eq(0)
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
    expect(Duse::Models::User.all.count).to eq(0)
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
    expect(Duse::Models::User.all.count).to eq(0)
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
    expect(Duse::Models::User.all.count).to eq(0)
  end

  it 'should not validate further than blanks when nothing is given' do
    post '/v1/users', '{}', 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect(last_response.body).to eq({
      'message' => [
        'Username must not be blank',
        'Password must not be blank',
        'Public key must not be blank'
      ]
    }.to_json)
    expect(Duse::Models::User.all.count).to eq(0)
  end

  it 'should respond to listing users correctly' do
    user = create_default_user
    token = TokenFacade.new(user).create!

    header 'Authorization', token
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

  it 'should return the correct user when request own profile' do
    public_key = generate_public_key
    user = create_default_user(public_key: public_key)
    token = TokenFacade.new(user).create!

    header 'Authorization', token
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
    token = TokenFacade.new(user).create!
    server_user = Duse::Models::Server.get

    header 'Authorization', token
    get '/v1/users/server', 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq({
      id: server_user.id,
      username: 'server',
      public_key: server_user.public_key.to_s,
      url: "http://example.org/v1/users/#{server_user.id}"
    }.to_json)
  end

  it 'should be able to delete ones own user' do
    user = create_default_user
    token = TokenFacade.new(user).create!

    header 'Authorization', token
    delete "/v1/users/#{user.id}", 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq 204
  end

  it 'should error with not found when trying to delete not existant user' do
    user = create_default_user
    token = TokenFacade.new(user).create!

    header 'Authorization', token
    # user.id + 1 should be a non existant id
    delete "/v1/users/#{user.id+1}", 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq 404
  end

  it 'should error with forbidden when deleting a user without permission to' do
    user1 = create_default_user
    user2 = create_default_user(username: 'user2')
    token = TokenFacade.new(user1).create!

    header 'Authorization', token
    delete "/v1/users/#{user2.id}", 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq 403
  end

  it 'should be able to update a user' do
    user = create_default_user
    token = TokenFacade.new(user).create!

    header 'Authorization', token
    patch "/v1/users/#{user.id}", {username: 'works'}.to_json, 'CONTENT_TYPE' => 'application/json'

    user = Duse::Models::User.find(user.id)
    expect(user.username).to eq 'works'
  end
end

