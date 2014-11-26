describe User do
  before :each do
    DatabaseCleaner.start
  end

  after :each do
    DatabaseCleaner.clean
  end

  it 'should be able to save and retrieve a public key' do
    key = generate_key
    user = User.create(username: 'test', password: 'Passw0rd!', password_confirmation: 'Passw0rd!', public_key: key.public_key)
    expect(user.public_key.class).to eq(OpenSSL::PKey::RSA)
  end

  it 'should correctly handle plain text public keys' do
    key = generate_key
    user = User.create(username: 'test', password: 'Passw0rd!', password_confirmation: 'Passw0rd!', public_key: key.public_key.to_s)
    expect(user.public_key.class).to eq(OpenSSL::PKey::RSA)
  end

  it 'should handle encryption/signing/verification correctly' do
    key = generate_key
    user = User.create(username: 'test', password: 'Passw0rd!', password_confirmation: 'Passw0rd!', public_key: key.public_key)
    encrypted, signature = user.encrypt key, 'test'
    expect(user.verify_authenticity signature, encrypted).to be true
    expect(Encryption.decrypt key, encrypted).to eq 'test'
  end

  it 'should correctly handle non public keys' do
    public_key = 'not a public key'
    user = User.new username: 'test', password: 'Passw0rd!', password_confirmation: 'Passw0rd!', public_key: public_key
    expect(user.valid?).to be false
    expect(user.errors.full_messages).to eq(["Public key is not a valid RSA Public Key."])
  end
end
