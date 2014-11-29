describe Share do

  before :each do
    DatabaseCleaner.start
  end

  after :each do
    DatabaseCleaner.clean
  end

  it 'a correctly encrypted and signed share should not raise errors' do
    server = User.create username: 'server', password: 'Passw0rd!', password_confirmation: 'Passw0rd!', public_key: generate_public_key
    user_key = generate_key
    user = User.create username: 'test', password: 'Passw0rd!', password_confirmation: 'Passw0rd!', public_key: user_key.public_key
    secret = Secret.create title: 'secret', required: 2, last_edited_by: user
    secret_part = SecretPart.create index: 0, secret: secret
    content, signature = server.encrypt user_key, 'share1'
    share = Share.new content: content, signature: signature, secret_part: secret_part, user: server
    expect(share.valid?).to be true
    share.save
  end
end
