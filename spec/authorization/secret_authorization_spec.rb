require 'duse/api/authorization/secret'

describe Duse::API::Authorization do
  it 'should allow access for a user the secrets belongs to' do
    server = Duse::API::Models::Server.find_or_create
    user_key = KeyHelper.generate_key
    user = create(:user, public_key: user_key.public_key)
    secret = Duse::API::Models::Secret.create title: 'secret', cipher_text: 'someciphertext==', last_edited_by: user, users: [server, user]
    content1, signature1 = server.encrypt user_key, 'share1'
    content2, signature2 = user.encrypt user_key, 'share2'
    Duse::API::Models::Share.create(
      content: content1,
      signature: signature1,
      secret: secret,
      user: server
    )
    Duse::API::Models::Share.create(
      content: content2,
      signature: signature2,
      secret: secret,
      user: user
    )

    Duse::API::Authorization::Secret.authorize!(user, :read, secret)
  end

  it 'should not allow access for a user the secrets does not belong to' do
    server = Duse::API::Models::Server.find_or_create
    user_key = KeyHelper.generate_key
    user = create(:user, public_key: user_key.public_key)
    secret = Duse::API::Models::Secret.create title: 'secret', cipher_text: 'someciphertext==', last_edited_by: user, users: [server, user]
    content1, signature1 = server.encrypt user_key, 'share1'
    content2, signature2 = user.encrypt user_key, 'share2'
    Duse::API::Models::Share.create(
      content: content1,
      signature: signature1,
      secret: secret,
      user: server
    )
    Duse::API::Models::Share.create(
      content: content2,
      signature: signature2,
      secret: secret,
      user: user
    )
    other_user = create(:user)

    expect do
      Duse::API::Authorization::Secret.authorize!(other_user, :read, secret)
    end.to raise_error(Duse::API::InvalidAuthorization)
  end

  it 'should allow by default when no block is given' do
    authorization = Class.new(Duse::API::Authorization::Base)
    authorization.allow :create
    user = create(:user)

    authorization.authorize! user, :create, {}
  end
end

