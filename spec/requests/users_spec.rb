require 'rack/test'
require 'json'

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
    user_json = { username: 'test', password: 'password' }.to_json
    post '/v1/users', user_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(201)
    user_id = User.first(username: 'test').id
    expect(last_response.body).to eq(
      {
        id: user_id,
        username: 'test',
        url: "http://example.org/v1/users/#{user_id}"
      }.to_json
    )
    expect(User.all.count).to eq(1)
  end

  it 'should error when a username is not given' do
    user_json = { password: 'test1' }.to_json
    post '/v1/users', user_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect(User.all.count).to eq(0)
  end

  it 'should not put the api token in the json response' do
    user = User.create username: 'test', password: 'password'

    header 'Authorization', user.api_token
    get "/v1/users/#{user.id}", 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(200)
    expect(JSON.parse(last_response.body).key? 'api_token').to eq(false)
  end

  it 'should respond to listing users correctly' do
    user = User.create username: 'test', password: 'password'

    header 'Authorization', user.api_token
    get '/v1/users', 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq(
      [{
        id: user.id,
        username: user.username,
        url: "http://example.org/v1/users/#{user.id}"
      }].to_json
    )
  end

  it 'should return the users api token correctly' do
    user = User.create username: 'test', password: 'test-password'
    post '/v1/users/token', {
      username: 'test',
      password: 'test-password'
    }.to_json, 'CONTENT_TYPE' => 'application/json'
    expect(last_response.body).to eq(
      { 'api_token' => user.api_token }.to_json
    )
  end

  it 'should return unauthenticated on wrong password' do
    User.create username: 'test', password: 'test-password'
    post '/v1/users/token', {
      username: 'test',
      password: 'wrong-password'
    }.to_json, 'CONTENT_TYPE' => 'application/json'
    expect(last_response.status).to eq(401)
  end
end
