describe Share do

  before :each do
    DatabaseCleaner.start
  end

  after :each do
    DatabaseCleaner.clean
  end

  it 'a correctly encrypted and signed share should not raise errors' do
    server = User.create username: 'server', password: 'test-password', public_key: generate_public_key
    user_key = generate_key
    user = User.create username: 'test', password: 'test-password', public_key: user_key.public_key.to_s
    secret = Secret.create title: 'secret', required: 2, last_edited_by: user
    secret_part = SecretPart.create index: 0, secret: secret
    digest = OpenSSL::Digest::SHA256.new
    encrypted_share = OpenSSL::PKey::RSA.new(server.public_key).public_encrypt 'share1'
    signature_share = user_key.sign digest, encrypted_share
    Share.create content: encrypted_share, signature: signature_share, secret_part: secret_part, user: server
  end
end
