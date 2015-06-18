describe Duse::API do
  include Rack::Test::Methods

  def app
    Duse::API::App.new
  end

  it 'should persist the user correctly and send a confirmation email' do
    user_json = {
      username: 'flower-pot',
      email: 'flower-pot@example.org',
      password: 'Passw0rd!',
      password_confirmation: 'Passw0rd!',
      public_key: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmMm3Ovh7gU0rLHK4NiHh\nWaYRrV9PH6XtHqV0GoiHH7awrjVkT1aZiS+nlBxckfuvuQjRXakVCZh18UdQadVQ\n7FLTWMZNoZ/uh41g4Iv17Wh1I3Fgqihdm83cSWvJ81qQCVGBaKeVitSa49zT/Mmo\noBvYFwulaqJjhqFc3862Rl3WowzGVqGf+OiYhFrBbnIqXijDmVKsbqkG5AILGo1n\nng06HIAvMqUcGMebgoju9SuKaR+C46KT0K5sPpNw/tNcDEZqZAd25QjAroGnpRHS\nI9hTEuPopPSyRqz/EVQfbhi0LbkdDW9S5ECw7GfFPFpRp2239fjl/9ybL6TkeZL7\nAwIDAQAB\n-----END PUBLIC KEY-----\n"
    }.to_json

    expect{
      post '/v1/users', user_json, 'CONTENT_TYPE' => 'application/json'
    }.to change{Duse::Models::User.all.count}.by(1)
    expect(last_response.status).to eq(201)
    user = Duse::Models::User.find_by_username('flower-pot')
    expect(last_response.body).to eq(
      {
        id: user.id,
        username: 'flower-pot',
        email: 'flower-pot@example.org',
        public_key: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmMm3Ovh7gU0rLHK4NiHh\nWaYRrV9PH6XtHqV0GoiHH7awrjVkT1aZiS+nlBxckfuvuQjRXakVCZh18UdQadVQ\n7FLTWMZNoZ/uh41g4Iv17Wh1I3Fgqihdm83cSWvJ81qQCVGBaKeVitSa49zT/Mmo\noBvYFwulaqJjhqFc3862Rl3WowzGVqGf+OiYhFrBbnIqXijDmVKsbqkG5AILGo1n\nng06HIAvMqUcGMebgoju9SuKaR+C46KT0K5sPpNw/tNcDEZqZAd25QjAroGnpRHS\nI9hTEuPopPSyRqz/EVQfbhi0LbkdDW9S5ECw7GfFPFpRp2239fjl/9ybL6TkeZL7\nAwIDAQAB\n-----END PUBLIC KEY-----\n",
        url: "http://example.org/v1/users/#{user.id}"
      }.to_json
    )
  end

  it 'should successfully confirm the user when using the confirmation token' do
    user_json = {
      username: 'test',
      email: 'test@example.org',
      password: 'Passw0rd!',
      password_confirmation: 'Passw0rd!',
      public_key: KeyHelper.generate_public_key
    }.to_json
    post '/v1/users', user_json, 'CONTENT_TYPE' => 'application/json'

    mail = Mail::TestMailer.deliveries.first
    expect(mail.to).to eq ['test@example.org']
    expect(mail.from).to eq ['noreply@example.org']
    expect(mail.subject).to eq 'Confirm your signup'

    words = mail.html_part.to_s.split
    confirmation_token = words.last
    confirmation_token = confirmation_token[0..-2]
    patch "/v1/users/confirm", { token: confirmation_token }.to_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq 204
    user = Duse::Models::User.find_by_username('test') # we need the new values
    expect(user.confirmed?).to be true
    expect(user.confirmation_tokens.length).to be 0
  end

  it 'should create a new confirmation process' do
    user = create(:user, confirmed_at: nil)
    post '/v1/users/confirm', { email: user.email }.to_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq 204
    mail = Mail::TestMailer.deliveries.first
    expect(mail.to).to eq [user.email]
    expect(mail.from).to eq ['noreply@example.org']
    expect(mail.subject).to eq 'Confirm your signup'
  end

  it 'should create a new confirmation process' do
    user = create(:user)
    post '/v1/users/confirm', { email: user.email }.to_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq 400
    expect(last_response.body).to eq({
      message: 'Account already confirmed'
    }.to_json)
  end

  it 'should remove all confirmation tokens but the latest' do
    user_json = {
      username: 'test',
      email: 'test@example.org',
      password: 'Passw0rd!',
      password_confirmation: 'Passw0rd!',
      public_key: KeyHelper.generate_public_key
    }.to_json
    post '/v1/users', user_json, 'CONTENT_TYPE' => 'application/json'

    user = Duse::Models::User.find_by_username 'test'
    post '/v1/users/confirm', { email: user.email }.to_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq 204
    expect(user.confirmation_tokens.length).to eq 1
  end

  it 'should send an email with the reset token when requesting password reset' do
    user = create(:user)
    post '/v1/users/forgot_password', { email: user.email }.to_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq 204
    mail = Mail::TestMailer.deliveries.first
    expect(mail.to).to eq [user.email]
    expect(mail.from).to eq ['noreply@example.org']
    expect(mail.subject).to eq 'Reset your password'
    words = mail.html_part.to_s.split
    reset_token = words.last

    patch '/v1/users/password', { token: reset_token, password: 'Passw000rd!' }.to_json, 'CONTENT_TYPE' => 'application/json'
    expect(last_response.status).to eq 204
    expect(Duse::Models::User.find_by_username(user.username).try(:authenticate, 'Passw000rd!')).to be_truthy
  end

  it 'should error when a username is not given' do
    user_json = {
      email: 'flower-pot@example.org',
      password: 'Passw0rd!',
      password_confirmation: 'Passw0rd!',
      public_key: KeyHelper.generate_public_key
    }.to_json

    expect{
      post '/v1/users', user_json, 'CONTENT_TYPE' => 'application/json'
    }.not_to change{Duse::Models::User.all.count}
    expect(last_response.status).to eq(422)
    expect(last_response.body).to eq({
      'message' => ['Username must not be blank']
    }.to_json)
  end

  it 'should error if a username is already taken' do
    Duse::Models::User.create(username: 'test', email: 'test@example.org', password: 'test')
    user_json = {
      username: 'test',
      email: 'test2@example.org',
      password: 'Passw0rd!',
      password_confirmation: 'Passw0rd!',
      public_key: KeyHelper.generate_public_key
    }.to_json

    expect{
      post '/v1/users', user_json, 'CONTENT_TYPE' => 'application/json'
    }.not_to change{Duse::Models::User.all.count}
    expect(last_response.status).to eq(422)
    expect(last_response.body).to eq({
      'message' => ['Username has already been taken']
    }.to_json)
  end

  it 'should error when an email is not given' do
    user_json = {
      username: 'test',
      password: 'Passw0rd!',
      password_confirmation: 'Passw0rd!',
      public_key: KeyHelper.generate_public_key
    }.to_json

    expect{
      post '/v1/users', user_json, 'CONTENT_TYPE' => 'application/json'
    }.not_to change{Duse::Models::User.all.count}
    expect(last_response.status).to eq(422)
    expect(last_response.body).to eq({
      'message' => ['Email must not be blank']
    }.to_json)
  end

  it 'should error if an email is already taken' do
    Duse::Models::User.create(username: 'test', email: 'test@example.org', password: 'test')
    user_json = {
      username: 'test2',
      email: 'test@example.org',
      password: 'Passw0rd!',
      password_confirmation: 'Passw0rd!',
      public_key: KeyHelper.generate_public_key
    }.to_json

    expect{
      post '/v1/users', user_json, 'CONTENT_TYPE' => 'application/json'
    }.not_to change{Duse::Models::User.all.count}
    expect(last_response.status).to eq(422)
    expect(last_response.body).to eq({
      'message' => ['Email has already been taken']
    }.to_json)
  end

  it 'should error when an email address is invalid' do
    user_json = {
      username: 'test2',
      email: 'test@not-a-host-name-we-accept',
      password: 'Passw0rd!',
      password_confirmation: 'Passw0rd!',
      public_key: KeyHelper.generate_public_key
    }.to_json

    expect{
      post '/v1/users', user_json, 'CONTENT_TYPE' => 'application/json'
    }.not_to change{Duse::Models::User.all.count}
    expect(last_response.status).to eq(422)
    expect(last_response.body).to eq({
      'message' => ['Email is not a valid email address']
    }.to_json)
  end

  it 'should error when a username contains illegal characters' do
    user_json = {
      username: 'test?',
      email: 'test@example.org',
      password: 'Passw0rd!',
      password_confirmation: 'Passw0rd!',
      public_key: KeyHelper.generate_public_key
    }.to_json

    expect{
      post '/v1/users', user_json, 'CONTENT_TYPE' => 'application/json'
    }.not_to change{Duse::Models::User.all.count}
    expect(last_response.status).to eq(422)
    expect(last_response.body).to eq({
      'message' => ['Username must be only letters, numbers, "-" and "_"']
    }.to_json)
  end

  it 'should correctly handle non rsa public keys' do
    user_json = {
      username: 'test',
      email: 'test@example.org',
      password: 'Passw0rd!',
      password_confirmation: 'Passw0rd!',
      public_key: 'non rsa public key'
    }.to_json

    expect{
      post '/v1/users', user_json, 'CONTENT_TYPE' => 'application/json'
    }.not_to change{Duse::Models::User.all.count}
    expect(last_response.status).to eq(422)
    expect(last_response.body).to eq({
      'message' => ['Public key is not a valid RSA Public Key']
    }.to_json)
  end

  it 'should correctly handle no rsa public key' do
    user_json = {
      username: 'test',
      email: 'test@example.org',
      password: 'Passw0rd!',
      password_confirmation: 'Passw0rd!'
    }.to_json

    expect{
      post '/v1/users', user_json, 'CONTENT_TYPE' => 'application/json'
    }.not_to change{Duse::Models::User.all.count}
    expect(last_response.status).to eq(422)
    expect(last_response.body).to eq({
      'message' => ['Public key must not be blank']
    }.to_json)
  end

  it 'should not validate further than blanks when nothing is given' do
    expect{
      post '/v1/users', '{}', 'CONTENT_TYPE' => 'application/json'
    }.not_to change{Duse::Models::User.all.count}
    expect(last_response.status).to eq(422)
    expect(last_response.body).to eq({
      'message' => [
        'Username must not be blank',
        'Email must not be blank',
        'Password must not be blank',
        'Public key must not be blank'
      ]
    }.to_json)
  end

  it 'should be able to retrieve single users' do
    user1 = create(:user)
    user2 = create(:user)

    header 'Authorization', user1.create_new_token
    get "/v1/users/#{user2.id}"

    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq({
      id: user2.id,
      username: user2.username,
      email: user2.email,
      public_key: user2.public_key.to_s,
      url: "http://example.org/v1/users/#{user2.id}"
    }.to_json)
  end

  it 'should respond to listing users correctly' do
    user = create(:user)
    token = user.create_new_token

    header 'Authorization', token
    get '/v1/users', 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq(
      [{
        id: user.id,
        username: user.username,
        email: user.email,
        url: "http://example.org/v1/users/#{user.id}"
      }].to_json
    )
  end

  it 'should return the correct user when request own profile' do
    user = create(:user)
    token = user.create_new_token

    header 'Authorization', token
    get '/v1/users/me', 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq({
      id: user.id,
      username: user.username,
      email: user.email,
      public_key: user.public_key.to_s,
      url: "http://example.org/v1/users/#{user.id}"
    }.to_json)
  end

  it 'should return the correct user when requesting the server user' do
    user = create(:user)
    token = user.create_new_token
    server_user = Duse::Models::Server.get

    header 'Authorization', token
    get '/v1/users/server', 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq({
      id: server_user.id,
      username: 'server',
      email: 'server@localhost',
      public_key: server_user.public_key.to_s,
      url: "http://example.org/v1/users/#{server_user.id}"
    }.to_json)
  end

  it 'should be able to delete ones own user' do
    user = create(:user)
    token = user.create_new_token

    header 'Authorization', token
    delete "/v1/users/#{user.id}", 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq 204
  end

  it 'should error with not found when trying to delete not existant user' do
    user = create(:user)
    token = user.create_new_token

    header 'Authorization', token
    # user.id + 1 should be a non existant id
    delete "/v1/users/#{user.id+1}", 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq 404
  end

  it 'should error with forbidden when deleting a user without permission to' do
    user1 = create(:user)
    user2 = create(:user)
    token = user1.create_new_token

    header 'Authorization', token
    delete "/v1/users/#{user2.id}", 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq 403
  end

  it 'should be able to update a user' do
    user = create(:user)
    token = user.create_new_token

    header 'Authorization', token
    patch "/v1/users/#{user.id}", { username: 'works', current_password: 'Passw0rd!' }.to_json, 'CONTENT_TYPE' => 'application/json'

    user.reload
    expect(user.username).to eq 'works'
    expect(last_response.status).to eq 200
  end

  it 'should not error when unnecessary properties are provided' do
    post "/v1/users", {test: 'test'}.to_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq 422
  end

  it 'validates that a users public key is 2048 bit size or larger' do
    user_json = {
      username: 'flower-pot',
      email: 'flower-pot@example.org',
      password: 'Passw0rd!',
      password_confirmation: 'Passw0rd!',
      public_key: KeyHelper.generate_public_key(1024)
    }.to_json

    expect{
      post '/v1/users', user_json, 'CONTENT_TYPE' => 'application/json'
    }.not_to change{Duse::Models::User.all.count}
    expect(last_response.status).to eq(422)
    expect(last_response.body).to eq({
      'message' => ['Public key size must be 2048 bit or larger']
    }.to_json)
  end
end

