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

    post '/v1/users/token', {
      username: 'wrong-username',
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
    token = TokenFacade.new(user).create!

    header 'Authorization', token
    get '/v1/users/me', 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq 200
  end
end
