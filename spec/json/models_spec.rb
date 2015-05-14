describe SecretJSON do

  before :each do
    DatabaseCleaner.start
  end

  after :each do
    DatabaseCleaner.clean
  end

  it 'should validate secrets correctly' do
    key = KeyHelper.generate_key
    server = Duse::Models::Server.get
    user1  = create :user, public_key: key.public_key.to_s
    user2  = create :user

    json = SecretJSON.new({
      title: 'My secret',
      cipher_text: 'someciphertext==',
      shares: [
        share(server.id, 'share1', key, server.public_key),
        share(user1.id,  'share2', key, user1.public_key),
        share(user2.id,  'share3', key, user2.public_key)
      ]
    })

    json.validate!(current_user: user1)
  end
end

