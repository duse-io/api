describe Duse::Models::Token do
  include Rack::Test::Methods

  def app
    Duse::API
  end

  before :each do
    DatabaseCleaner.start
    Duse::Models::Server.ensure_user_exists
  end

  after :each do
    DatabaseCleaner.clean
  end

  it 'should return the users api token correctly' do
    user = create_default_user(username: 'test', password: 'Passw0rd!')

    post '/v1/users/token', {
      username: 'test',
      password: 'Passw0rd!'
    }.to_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(201)
  end

  it 'should return unauthenticated on wrong username' do
    create_default_user(username: 'test', password: 'Passw0rd!')

    post '/v1/users/token', {
      username: 'wrong-username',
      password: 'Passw0rd!'
    }.to_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(401)
  end

  it 'should return unauthenticated on wrong password' do
    user = create_default_user(username: 'test', password: 'Passw0rd!')

    post '/v1/users/token', {
      username: 'test',
      password: 'wrong-password'
    }.to_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(401)
  end

  it 'should return unauthenticated on not existant user' do
    post '/v1/users/token', {
      username: 'not-existant-user',
      password: 'some-password'
    }.to_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(401)
  end

  it 'should return unauthenticated when a wrong api token is set' do
    header 'Authorization', 'wrong-token'
    get '/v1/users/me', 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq 401
  end

  it 'should correctly authenticate with a correct token' do
    user = create_default_user(username: 'test', password: 'Passw0rd!')

    header 'Authorization', user.create_new_token
    get '/v1/users/me', 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq 200
  end

  it 'should return unauthenticated when token is older than 30 days' do
    user = create_default_user
    raw_token = user.create_new_token
    token = user.tokens.first
    token.update_column(:last_used_at, 31.days.ago)

    header 'Authorization', raw_token
    get '/v1/users/me', 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq 401
  end

  it 'should update the last used attribute when using a token' do
    user = create_default_user
    raw_token = user.create_new_token
    token = user.tokens.first
    token.update_column(:last_used_at, 2.days.ago)
    allow(Time).to receive(:now).and_return(Time.mktime(2015,1,1,0,0,0))

    header 'Authorization', raw_token
    get '/v1/users/me', 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq 200
    expect(user.tokens.first.last_used_at).to eq Time.mktime(2015,1,1,0,0,0)
  end
end
