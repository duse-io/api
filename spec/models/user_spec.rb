describe Duse::Models::User do
  before :each do
    DatabaseCleaner.start
  end

  after :each do
    DatabaseCleaner.clean
  end

  context :public_key do
    it 'should be able to save and retrieve a public key' do
      key = generate_key
      user = Duse::Models::User.create(
        username: 'test',
        password: 'Passw0rd!',
        password_confirmation: 'Passw0rd!',
        public_key: key.public_key
      )
      expect(user.public_key.class).to eq(OpenSSL::PKey::RSA)
    end

    it 'should correctly handle plain text public keys' do
      key = generate_key
      user = Duse::Models::User.create(
        username: 'test',
        password: 'Passw0rd!',
        password_confirmation: 'Passw0rd!',
        public_key: key.public_key.to_s
      )
      expect(user.public_key.class).to eq(OpenSSL::PKey::RSA)
    end

    it 'should handle encryption/signing/verification correctly' do
      key = generate_key
      user = Duse::Models::User.create(
        username: 'test',
        password: 'Passw0rd!',
        password_confirmation: 'Passw0rd!',
        public_key: key.public_key
      )
      encrypted, signature = user.encrypt key, 'test'
      expect(user.verify_authenticity signature, encrypted).to be true
      expect(Encryption.decrypt key, encrypted).to eq 'test'
    end

    it 'should reject everything that\'s not a public rsa keys' do
      public_key = 'not a public key'
      user = Duse::Models::User.new(
        username: 'test',
        password: 'Passw0rd!',
        password_confirmation: 'Passw0rd!',
        public_key: public_key
      )
      expect(user.valid?).to be false
      expect(user.errors.full_messages).to eq([
        'Public key is not a valid RSA Public Key.'
      ])
    end
  end

  context :username do
    it 'should make sure that usernames are only alphanumeric' do
      key = generate_key
      user = Duse::Models::User.new(
        username: 'test?',
        password: 'Passw0rd!',
        password_confirmation: 'Passw0rd!',
        public_key: key.public_key.to_s
      )
      expect(user.valid?).to be false
      expect(user.errors.full_messages).to eq([
        'Username must be only letters, numbers, "-" and "_"'
      ])
    end

    it 'should make sure that usernames are at least 4 characters long' do
      key = generate_key
      user = Duse::Models::User.new(
        username: 'tst',
        password: 'Passw0rd!',
        password_confirmation: 'Passw0rd!',
        public_key: key.public_key.to_s
      )
      expect(user.valid?).to be false
      expect(user.errors.full_messages).to eq([
        'Username must be between 4 and 30 characters long'
      ])
    end

    it 'should make sure that usernames are unique' do
      key = generate_key
      Duse::Models::User.create(
        username: 'test',
        password: 'Passw0rd!',
        password_confirmation: 'Passw0rd!',
        public_key: key.public_key.to_s
      )
      user = Duse::Models::User.new(
        username: 'test',
        password: 'Passw0rd!',
        password_confirmation: 'Passw0rd!',
        public_key: key.public_key.to_s
      )
      expect(user.valid?).to be false
      expect(user.errors.full_messages).to eq(['Username is already taken'])
    end
  end

  context :password do
    it 'should prevent weak passwords' do
      key = generate_key
      user = Duse::Models::User.new(
        username: 'test',
        password: 'password',
        password_confirmation: 'password',
        public_key: key.public_key.to_s
      )
      expect(user.valid?).to be false
      expect(user.errors.full_messages).to eq(['Password too weak.'])
    end

    it 'should view "_" as a special character' do
      key = generate_key
      password = 'Passw0rd_'
      user = Duse::Models::User.new(
        username: 'test',
        password: password,
        password_confirmation: password,
        public_key: key.public_key.to_s
      )
      expect(user.valid?).to be true
    end

    it 'should check that passwords are at least 8 characters long' do
      key = generate_key
      user = Duse::Models::User.new(
        username: 'test',
        password: 'Psw0rd!',
        password_confirmation: 'Psw0rd!',
        public_key: key.public_key.to_s
      )
      expect(user.valid?).to be false
      expect(user.errors.full_messages).to eq([
        'Password must be at least 8 characters long'
      ])
    end

    it 'should check that password confirmation equals password' do
      key = generate_key
      user = Duse::Models::User.new(
        username: 'test',
        password: 'password',
        password_confirmation: 'Passw0rd!',
        public_key: key.public_key.to_s
      )
      expect(user.valid?).to be false
      expect(user.errors.full_messages).to eq([
        'Password and password confirmation do not match'
      ])
    end
  end
end
