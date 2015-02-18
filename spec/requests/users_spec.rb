describe Duse::API do
  include Rack::Test::Methods

  def app
    Duse::API::App.new
  end

  before :each do
    DatabaseCleaner.start
    Mail::TestMailer.deliveries.clear
  end

  after :each do
    DatabaseCleaner.clean
  end

  it 'should persist the user correctly and send a confirmation email' do
    user_json = {
      username: 'flower-pot',
      email: 'flower-pot@example.org',
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
    user = Duse::Models::User.find_by_username('flower-pot')
    expect(last_response.body).to eq(
      {
        id: user.id,
        username: 'flower-pot',
        email: 'flower-pot@example.org',
        public_key: "-----BEGIN PUBLIC KEY-----\n" \
        "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDR1pYkhBVekZZvcgRaMR6iZTJt\n" \
        "fr6ALzIg1MHkkWonMXIJ5qvN+3Xeucf8Wk6c8I01T2PviQtnw/h+NjkBcvTKi/3y\n" \
        "2eMatpsu1QK5iaarWx25RcfFCkcElBZ8FibMfC2/DH+11kKIjlQN3iZaC3qd2Mpq\n" \
        "a042HsjIOuVQqTb/mQIDAQAB\n" \
        "-----END PUBLIC KEY-----\n",
        url: "http://example.org/v1/users/#{user.id}"
      }.to_json
    )
    expect(Duse::Models::User.all.count).to eq(1)
  end

  it 'should successfully confirm the user when using the confirmation token' do
    user_json = {
      username: 'test',
      email: 'test@example.org',
      password: 'Passw0rd!',
      password_confirmation: 'Passw0rd!',
      public_key: generate_public_key
    }.to_json
    post '/v1/users', user_json, 'CONTENT_TYPE' => 'application/json'

    mail = Mail::TestMailer.deliveries.first
    expect(mail.to).to eq ['test@example.org']
    expect(mail.from).to eq ['noreply@example.org']
    expect(mail.subject).to eq 'Confirm your signup'

    words = mail.html_part.to_s.split
    confirmation_token = words.last
    patch "/v1/users/confirm", { token: confirmation_token }.to_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq 204
    user = Duse::Models::User.find_by_username('test') # we need the new values
    expect(user.confirmed?).to be true
    expect(user.confirmation_tokens.length).to be 0
  end

  it 'should create a new confirmation process' do
    user = create_default_user
    user.update(confirmed_at: nil)
    post '/v1/users/confirm', { email: user.email }.to_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq 201
    mail = Mail::TestMailer.deliveries.first
    expect(mail.to).to eq ['test@example.org']
    expect(mail.from).to eq ['noreply@example.org']
    expect(mail.subject).to eq 'Confirm your signup'
  end

  it 'should create a new confirmation process' do
    user = create_default_user
    user.confirm!
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
      public_key: generate_public_key
    }.to_json
    post '/v1/users', user_json, 'CONTENT_TYPE' => 'application/json'

    user = Duse::Models::User.find_by_username 'test'
    post '/v1/users/confirm', { email: user.email }.to_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq 201
    expect(user.confirmation_tokens.length).to eq 1
  end

  it 'should send an email with the reset token when requesting password reset' do
    user = create_default_user
    post '/v1/users/forgot_password', { email: user.email }.to_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq 201
    mail = Mail::TestMailer.deliveries.first
    expect(mail.to).to eq ['test@example.org']
    expect(mail.from).to eq ['noreply@example.org']
    expect(mail.subject).to eq 'Reset your password'
    words = mail.html_part.to_s.split
    reset_token = words.last

    patch '/v1/users/password', { token: reset_token, password: 'Passw000rd!' }.to_json, 'CONTENT_TYPE' => 'application/json'
    expect(last_response.status).to eq 204
    expect(Duse::Models::User.find_by_username('test').try(:authenticate, 'Passw000rd!')).to be_truthy
  end

  it 'should error when a username is not given' do
    user_json = {
      email: 'flower-pot@example.org',
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

  it 'should error if a username is already taken' do
    Duse::Models::User.create(username: 'test', email: 'test@example.org', password: 'test')
    user_json = {
      username: 'test',
      email: 'test2@example.org',
      password: 'Passw0rd!',
      password_confirmation: 'Passw0rd!',
      public_key: generate_public_key
    }.to_json

    post '/v1/users', user_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect(last_response.body).to eq({
      'message' => ['Username has already been taken']
    }.to_json)
    expect(Duse::Models::User.all.count).to eq(1)
  end

  it 'should error when an email is not given' do
    user_json = {
      username: 'test',
      password: 'Passw0rd!',
      password_confirmation: 'Passw0rd!',
      public_key: generate_public_key
    }.to_json
    post '/v1/users', user_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect(last_response.body).to eq({
      'message' => ['Email must not be blank']
    }.to_json)
    expect(Duse::Models::User.all.count).to eq(0)
  end

  it 'should error if an email is already taken' do
    Duse::Models::User.create(username: 'test', email: 'test@example.org', password: 'test')
    user_json = {
      username: 'test2',
      email: 'test@example.org',
      password: 'Passw0rd!',
      password_confirmation: 'Passw0rd!',
      public_key: generate_public_key
    }.to_json

    post '/v1/users', user_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect(last_response.body).to eq({
      'message' => ['Email has already been taken']
    }.to_json)
    expect(Duse::Models::User.all.count).to eq(1)
  end

  it 'should error when an email address is invalid' do
    user_json = {
      username: 'test2',
      email: 'test@not-a-host-name-we-accept',
      password: 'Passw0rd!',
      password_confirmation: 'Passw0rd!',
      public_key: generate_public_key
    }.to_json

    post '/v1/users', user_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect(last_response.body).to eq({
      'message' => ['Email is not a valid email address']
    }.to_json)
    expect(Duse::Models::User.all.count).to eq(0)
  end

  it 'should error when a username contains illegal characters' do
    user_json = {
      username: 'test?',
      email: 'test@example.org',
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
      email: 'test@example.org',
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
      email: 'test@example.org',
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
        'Email must not be blank',
        'Password must not be blank',
        'Public key must not be blank'
      ]
    }.to_json)
    expect(Duse::Models::User.all.count).to eq(0)
  end

  it 'should be able to retrieve single users' do
    user1 = create_default_user
    user2 = create_default_user(username: 'test2')

    header 'Authorization', user1.create_new_token
    get "/v1/users/#{user2.id}"

    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq({
      id: user2.id,
      username: 'test2',
      email: 'test2@example.org',
      public_key: user2.public_key.to_s,
      url: "http://example.org/v1/users/#{user2.id}"
    }.to_json)
  end

  it 'should respond to listing users correctly' do
    user = create_default_user
    token = user.create_new_token

    header 'Authorization', token
    get '/v1/users', 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq(
      [{
        id: user.id,
        username: 'test',
        email: 'test@example.org',
        url: "http://example.org/v1/users/#{user.id}"
      }].to_json
    )
  end

  it 'should return the correct user when request own profile' do
    public_key = generate_public_key
    user = create_default_user(public_key: public_key)
    token = user.create_new_token

    header 'Authorization', token
    get '/v1/users/me', 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq({
      id: user.id,
      username: 'test',
      email: 'test@example.org',
      public_key: public_key,
      url: "http://example.org/v1/users/#{user.id}"
    }.to_json)
  end

  it 'should return the correct user when requesting the server user' do
    user = create_default_user
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
    user = create_default_user
    token = user.create_new_token

    header 'Authorization', token
    delete "/v1/users/#{user.id}", 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq 204
  end

  it 'should error with not found when trying to delete not existant user' do
    user = create_default_user
    token = user.create_new_token

    header 'Authorization', token
    # user.id + 1 should be a non existant id
    delete "/v1/users/#{user.id+1}", 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq 404
  end

  it 'should error with forbidden when deleting a user without permission to' do
    user1 = create_default_user
    user2 = create_default_user(username: 'user2')
    token = user1.create_new_token

    header 'Authorization', token
    delete "/v1/users/#{user2.id}", 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq 403
  end

  it 'should be able to update a user' do
    user = create_default_user
    token = user.create_new_token

    header 'Authorization', token
    patch "/v1/users/#{user.id}", { username: 'works', current_password: 'Passw0rd!' }.to_json, 'CONTENT_TYPE' => 'application/json'

    user = Duse::Models::User.find(user.id)
    expect(user.username).to eq 'works'
    expect(last_response.status).to eq 200
  end

  it 'should not error when unnecessary properties are provided' do
    post "/v1/users", {test: 'test'}.to_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq 422
  end
end

