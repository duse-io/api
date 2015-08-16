describe Duse::API, type: :request do
  include JsonFactory

  def app
    Duse::API::App.new
  end

  it 'responds with 201 when creating' do
    secret_json = default_secret.to_json

    header 'Authorization', @user1.create_new_token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(201)
  end

  it 'persists a new secret correctly' do
    secret_json = default_secret.to_json
    token = @user1.create_new_token

    header 'Authorization', token
    expect {
      post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'
    }.to change{ Duse::API::Models::Secret.count }.by(1)
  end

  it 'renders the secret correctly when creating' do
    secret_json = default_secret.to_json
    token = @user1.create_new_token

    header 'Authorization', token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    secret_id = Duse::API::Models::Secret.last.id
    expect(last_response.body).to eq({
      id: secret_id,
      title: 'my secret',
      url: "http://example.org/v1/secrets/#{secret_id}"
    }.to_json)
  end

  it 'ensures the specified folder exists' do
    secret_json = default_secret(folder_id: 10000).to_json
    token = @user1.create_new_token

    header 'Authorization', token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.body).to eq({
      message: ['Folder does not exist']
    }.to_json)
  end

  it 'puts the secret in the specified folder' do
    @key = KeyHelper.generate_key
    @user1 = FactoryGirl.create(:user, public_key: @key.public_key)
    folder = FactoryGirl.create(:folder, user: @user1)
    secret_json = default_secret(folder_id: folder.id).to_json
    token = @user1.create_new_token

    header 'Authorization', token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'
    secret = JSON.parse(last_response.body)

    header 'Authorization', token
    get '/v1/folders', 'CONTENT_TYPE' => 'application/json'

    expect(last_response.body).to eq([{
      id: nil,
      name: @user1.username,
      subfolders: [{
        id: folder.id,
        name: 'testFolder',
        subfolders: [],
        secrets: [secret],
        url: "http://example.org/v1/folders/#{folder.id}"
      }],
      secrets: []
    }].to_json)
  end

  it 'allows updating the folder the secret lies in' do
    secret_json = default_secret.to_json
    token = @user1.create_new_token

    header 'Authorization', token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    secret = Duse::API::Models::Secret.find(JSON.parse(last_response.body)['id'])
    folder = FactoryGirl.create(:folder, user: @user1)

    header 'Authorization', token
    patch "/v1/secrets/#{secret.id}", { folder_id: folder.id }.to_json, 'CONTENT_TYPE' => 'application/json'

    secret.reload
    folder.reload
    expect(folder.secrets).to include(secret)
  end

  it 'it renders the secret correctly when getting it' do
    secret_json = default_secret.to_json
    token = @user1.create_new_token
    header 'Authorization', token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'
    secret_id = JSON.parse(last_response.body)['id']

    header 'Authorization', token
    get "/v1/secrets/#{secret_id}"
    users = Duse::API::Models::Secret.last.users.all.map do |user|
      {
        'id' => user.id,
        'username' => user.username,
        'email' => user.email,
        'public_key' => user.public_key.to_s,
        'url' => "http://example.org/v1/users/#{user.id}"
      }
    end
    response = JSON.parse last_response.body
    shares = response.delete('shares') # separately validate shares and secret

    expect(response).to eq({
      'id' => secret_id,
      'title' => 'my secret',
      'cipher_text' => 'someciphertext==',
      'users' => users,
      'url' => "http://example.org/v1/secrets/#{secret_id}",
    })

    expect(shares[0]['last_edited_by_id']).to eq Duse::API::Models::Server.get.id
    expect(Duse::Encryption::Asymmetric.decrypt(@key, shares[0]['content'])).to eq 'share1'
    expect(Duse::Encryption::Asymmetric.verify(Duse::API::Models::Server.public_key, shares[0]['signature'], shares[0]['content'])).to be true
    expect(shares[1]['last_edited_by_id']).to eq @user1.id
    expect(Duse::Encryption::Asymmetric.decrypt(@key, shares[1]['content'])).to eq 'share2'
    expect(Duse::Encryption::Asymmetric.verify(@key.public_key, shares[1]['signature'], shares[1]['content'])).to be true
  end

  it 'lists secrets correctly after they have been created' do
    secret_json = default_secret.to_json
    token = @user1.create_new_token
    header 'Authorization', token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    secret_id = JSON.parse(last_response.body)['id']
    header 'Authorization', token
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
  end

  it 'should error if an unauthorized user tries to access a secret' do
    secret_json = default_secret.to_json
    header 'Authorization', @user1.create_new_token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    header 'Authorization', create(:user).create_new_token
    secret_id = JSON.parse(last_response.body)['id']
    get "/v1/secrets/#{secret_id}", {}, 'CONTENT_TYPE' => 'application/json'
    expect(last_response.status).to eq(403)
    expect(last_response.body).to eq({
      message: 'You are not authorized to access a resource'
    }.to_json)
  end

  it 'should be able to delete a secret' do
    secret_json = default_secret.to_json
    token = @user1.create_new_token

    header 'Authorization', token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'
    expect(last_response.status).to eq(201)

    secret_id = JSON.parse(last_response.body)['id']
    header 'Authorization', token
    delete "/v1/secrets/#{secret_id}"
    expect(last_response.status).to eq(204)
    expect(last_response.body).to eq('')
  end

  it 'should return 404 for a non existant secret' do
    user = create(:user)

    header 'Authorization', user.create_new_token
    get '/v1/secrets/1', 'CONTENT_TYPE' => 'application/json'
    expect(last_response.status).to eq(404)
    expect(last_response.body).to eq({
      message: 'Not found'
    }.to_json)
  end

  it 'should not try to do semantic validate when json validation fails' do
    user = create(:user)
    secret_json = { title: 'test', parts: 'test' }.to_json

    header 'Authorization', user.create_new_token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
  end

  it 'should return errors if there are no parts given' do
    user = create(:user)
    secret_json = { title: 'test', parts: [] }.to_json

    header 'Authorization', user.create_new_token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
  end

  it 'should return errors if there are no shares given' do
    user = create(:user)
    secret_json = { title: 'test', cipher_text: 'someciphertext==', shares: [] }.to_json

    header 'Authorization', user.create_new_token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect(last_response.body).to eq({
      message: ['Shares must not be empty']
    }.to_json)
  end

  it 'should error on malformed json' do
    user = create(:user)

    header 'Authorization', user.create_new_token
    post '/v1/secrets', '{ ', 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(400)
  end

  it 'should error when title is empty' do
    secret_json = default_secret(title: '').to_json

    header 'Authorization', @user1.create_new_token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect(last_response.body).to eq(
      { 'message' => ['Title must not be blank'] }.to_json
    )
  end

  it 'should error if the provided users don\'t exist' do
    server = Duse::API::Models::Server.get
    key = KeyHelper.generate_key
    user = create(:user, public_key: key.public_key)
    # we're not creating user #3, which triggers this behaviour
    secret_json = {
      title: 'my secret',
      shares: [
        share(Duse::API::Models::Server.get.id, 'share1', key, server.public_key),
        share(user.id, 'share2', key, user.public_key),
        {
          user_id: 3,
          content: 'share3',
          signature: Duse::Encryption::Asymmetric.sign(key, 'share3')
        }
      ]
    }.to_json

    header 'Authorization', user.create_new_token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
  end

  it 'should error if there is no share for the server' do
    key = KeyHelper.generate_key
    user1 = create(:user, public_key: key.public_key)
    user2 = create(:user)
    secret_json = {
      title: 'my secret',
      cipher_text: 'someciphertext==',
      shares: [
        share(user1.id, 'share1', key, user1.public_key),
        share(user2.id, 'share2', key, user2.public_key)
      ]
    }.to_json

    header 'Authorization', user1.create_new_token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
  end

  it 'should error when there is more than one share per user' do
    server_user = Duse::API::Models::Server.get
    key = KeyHelper.generate_key
    user = create(:user, public_key: key.public_key)
    secret_json = {
      title: 'my secret',
      parts: [
        [
          share(server_user.id, 'share1', key, server_user.public_key),
          share(user.id, 'share2', key, user.public_key),
          share(user.id, 'share3', key, user.public_key)
        ]
      ]
    }.to_json

    header 'Authorization', user.create_new_token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
  end

  it 'should error when at least one of the provided users do not exist' do
    server_user = Duse::API::Models::Server.get
    key = KeyHelper.generate_key
    user = create(:user, public_key: key.public_key)
    secret_json = {
      title: 'my secret',
      parts: [
        [
          share(Duse::API::Models::Server.get.id, 'share1', key, server_user.public_key),
          share(user.id, 'share2', key, user.public_key),
          share(3, 'share3', key, user.public_key)
        ]
      ]
    }.to_json

    header 'Authorization', user.create_new_token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
  end

  it 'should error with 401 if the user does not provide an auth header' do
    post '/v1/secrets',
         default_secret.to_json,
         'CONTENT_TYPE' => 'application/json'
    expect(last_response.status).to eq(401)
  end

  it 'should be able to update the title of a secret and remember the modifier' do
    key = KeyHelper.generate_key
    user1 = create(:user, public_key: key.public_key)
    token = user1.create_new_token
    user2 = create(:user)
    secret_json = {
      title: 'my secret',
      cipher_text: 'someciphertext==',
      shares: [
        share(Duse::API::Models::Server.get.id, 'share1', key, Duse::API::Models::Server.public_key),
        share(user1.id, 'share2', key, user1.public_key),
        share(user2.id, 'share3', key, user2.public_key)
      ]
    }.to_json

    header 'Authorization', token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'
    expect(last_response.status).to eq 201

    new_secret_json = { title: 'new title' }.to_json
    secret = JSON.parse(last_response.body)
    header 'Authorization', token
    patch "/v1/secrets/#{secret['id']}",
          new_secret_json,
          'CONTENT_TYPE' => 'application/json'
    expect(last_response.status).to eq 200

    header 'Authorization', user1.create_new_token
    get "/v1/secrets/#{secret['id']}", 'CONTENT_TYPE' => 'application/json'

    expect(JSON.parse(last_response.body)['title']).to eq 'new title'
    expect(Duse::API::Models::Secret.find(secret['id']).last_edited_by).to eq user1
  end

  it 'remembers the user who last modified the shares' do
    user1_key = KeyHelper.generate_key
    user1 = create(:user, public_key: user1_key.public_key)
    user2_key = KeyHelper.generate_key
    user2 = create(:user, public_key: user2_key.public_key)
    secret_json = {
      title: 'my secret',
      cipher_text: 'someciphertext==',
      shares: [
        share(Duse::API::Models::Server.get.id, 'share1', user1_key, Duse::API::Models::Server.public_key),
        share(user1.id, 'share2', user1_key, user1.public_key),
        share(user2.id, 'share3', user1_key, user2.public_key)
      ]
    }.to_json

    header 'Authorization', user1.create_new_token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'
    expect(last_response.status).to eq 201

    new_secret_json = {
      shares: [
        share(Duse::API::Models::Server.get.id, 'new_share1', user2_key, Duse::API::Models::Server.public_key),
        share(user1.id, 'new_share2', user2_key, user1.public_key),
        share(user2.id, 'new_share3', user2_key, user2.public_key)
      ]
    }.to_json
    secret = JSON.parse(last_response.body)
    header 'Authorization', user2.create_new_token
    patch "/v1/secrets/#{secret['id']}",
          new_secret_json,
          'CONTENT_TYPE' => 'application/json'
    expect(last_response.status).to eq 200

    header 'Authorization', user1.create_new_token
    get "/v1/secrets/#{secret['id']}", 'CONTENT_TYPE' => 'application/json'

    expect(Duse::API::Models::Secret.find(secret['id']).shares.first.last_edited_by).to eq user2
    expect(Duse::API::Models::Secret.find(secret['id']).last_edited_by).to eq user1
  end

  it 'it should validate when updating just like when creating' do
    secret_json = default_secret.to_json
    token = @user1.create_new_token

    header 'Authorization', token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    secret = JSON.parse(last_response.body)
    expect(last_response.status).to eq 201

    header 'Authorization', token
    patch "/v1/secrets/#{secret['id']}", {
      'title' => ''
    }.to_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq 422
    expect(JSON.parse(last_response.body)['message']).to eq [
      'Title must not be blank'
    ]
  end

  it 'ensures the secret limit' do
    secret_json = default_secret.to_json
    token = @user1.create_new_token

    10.times do
      header 'Authorization', token
      post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'
      expect(last_response.status).to eq 201
    end

    header 'Authorization', token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'
    expect(last_response.status).to eq 422
    expect(JSON.parse(last_response.body)['message']).to eq [
      'Your limit of secrets has been reached'
    ]
  end

  it 'validates the length of the cipher text against the key size' do
    secret_json = default_secret
    # since its a 256 bytes or 2048 bits key any length but 256 bytes will fail
    secret_json[:shares].first[:content] = Duse::Encryption.encode(Random.new.bytes(129))
    secret_json = secret_json.to_json
    token = @user1.create_new_token

    header 'Authorization', token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq 422
    expect(JSON.parse(last_response.body)['message']).to eq [
      'Public key and share content lengths do not match',
      'Authenticity could not be verified. Wrong signature.'
    ]
  end

  it 'validates the cipher to be set non empty' do
    secret_json = default_secret(cipher_text: '').to_json
    token = @user1.create_new_token

    header 'Authorization', token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq 422
    expect(JSON.parse(last_response.body)['message']).to eq [
      'Cipher must not be blank'
    ]
  end

  it 'validates the cipher text length not to exceed 5000' do
    secret_json = default_secret(cipher_text: 'a' * 5004).to_json
    token = @user1.create_new_token

    header 'Authorization', token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq 422
    expect(JSON.parse(last_response.body)['message']).to eq [
      'Secret is too long'
    ]
  end

  it 'validates the cipher text to be base64 encoded' do
    secret_json = default_secret(cipher_text: 'a').to_json
    token = @user1.create_new_token

    header 'Authorization', token
    post '/v1/secrets', secret_json, 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq 422
    expect(JSON.parse(last_response.body)['message']).to eq [
      'Cipher is expected to be base64 encoded'
    ]
  end

  it 'does not error on empty body' do
    token = create(:user).create_new_token

    header 'Authorization', token
    post '/v1/secrets', '', 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq 422
  end
end

