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
    public_key = generate_public_key
    user_json = {
      username: 'test',
      password: 'Passw0rd!',
      password_confirmation: 'Passw0rd!',
      public_key: public_key
    }.to_json
    post '/v1/users', user_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(201)
    user_id = User.first(username: 'test').id
    expect(last_response.body).to eq(
      {
        id: user_id,
        username: 'test',
        public_key: public_key,
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
      'message' => ['Username must be only letters, capital letters, numbers, "-" and "_". And at least 4 characters long.']
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
    user = create_default_user(username: 'test')

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

  it 'should return the correct user when request own profile' do
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
