describe User do

  before :each do
    DatabaseCleaner.start
  end

  after :each do
    DatabaseCleaner.clean
  end

  it 'should be able to save and retrieve a public key' do
    key = generate_key
    user = User.create(username: 'test', password: 'test', public_key: key.public_key)
    expect(user.public_key.class).to eq(OpenSSL::PKey::RSA)
  end

  it 'should correctly handle plain text public keys and encryption' do
    key = generate_key
    user = User.create(username: 'test', password: 'test', public_key: key.public_key.to_s)
    encrypted, signature = Encryption.encrypt(key, user.public_key, 'test')
    expect(Encryption.verify user.public_key, signature, encrypted).to be true
  end

  it 'should correctly handle non public keys' do
    public_key = 'not a public key'
    user = User.new username: 'test', password: 'test', public_key: public_key
    expect(user.valid?).to be false
    expect(user.errors.full_messages).to eq(["Public key is not a valid RSA Public Key."])
  end
end
