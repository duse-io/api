describe Share do

  before :each do
    DatabaseCleaner.start
  end

  after :each do
    DatabaseCleaner.clean
  end

  it 'a correctly encrypted and signed share should not raise errors' do
    server = Server.find_or_create
    user_key = generate_key
    user = create_default_user(public_key: user_key.public_key)
    secret = Secret.create title: 'secret', required: 2, last_edited_by: user
    secret_part = SecretPart.create index: 0, secret: secret
    content, signature = server.encrypt user_key, 'share1'
    share = Share.new(
      content: content,
      signature: signature,
      secret_part: secret_part,
      user: server
    )
    expect(share.valid?).to be true
    share.save
  end
end
