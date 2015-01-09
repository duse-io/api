describe Duse::Authorization do
  before :each do
    DatabaseCleaner.start
  end

  after :each do
    DatabaseCleaner.clean
  end

  it 'should allow access for a user the secrets belongs to' do
    server = Server.find_or_create
    user_key = generate_key
    user = create_default_user(public_key: user_key.public_key)
    secret = Secret.create title: 'secret', last_edited_by: user
    secret_part = SecretPart.create index: 0, secret: secret
    content1, signature1 = server.encrypt user_key, 'share1'
    content2, signature2 = user.encrypt user_key, 'share2'
    Share.create(
      content: content1,
      signature: signature1,
      secret_part: secret_part,
      user: server
    )
    Share.create(
      content: content2,
      signature: signature2,
      secret_part: secret_part,
      user: user
    )

    Duse::SecretAuthorization.authorize!(user, :read, secret)
  end

  it 'should not allow access for a user the secrets does not belong to' do
    server = Server.find_or_create
    user_key = generate_key
    user = create_default_user(public_key: user_key.public_key)
    secret = Secret.create title: 'secret', last_edited_by: user
    secret_part = SecretPart.create index: 0, secret: secret
    content1, signature1 = server.encrypt user_key, 'share1'
    content2, signature2 = user.encrypt user_key, 'share2'
    Share.create(
      content: content1,
      signature: signature1,
      secret_part: secret_part,
      user: server
    )
    Share.create(
      content: content2,
      signature: signature2,
      secret_part: secret_part,
      user: user
    )
    other_user = create_default_user(username: 'other_user')

    expect do
      Duse::SecretAuthorization.authorize!(other_user, :read, secret)
    end.to raise_error(Duse::InvalidAuthorization)
  end

  it 'should allow by default when no block is given' do
    class TestAuthorization < Duse::Authorization
      allow :create
    end

    user = create_default_user

    TestAuthorization.authorize! user, :create, {}
  end
end
