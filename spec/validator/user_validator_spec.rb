describe UserValidator do
  context :password do
    it 'should prevent weak passwords' do
      key = KeyHelper.generate_key
      user = {
        username: 'test',
        password: 'password',
        password_confirmation: 'password',
        public_key: key.public_key.to_s
      }
      expect(UserValidator.new.validate(user).to_a).to eq(['Password too weak'])
    end

    it 'should view "_" as a special character' do
      key = KeyHelper.generate_key
      password = 'Passw0rd_'
      user = {
        username: 'test',
        password: password,
        password_confirmation: password,
        public_key: key.public_key.to_s
      }
      expect(UserValidator.new.validate(user).to_a).to eq([])
    end

    it 'should check that passwords are at least 8 characters long' do
      key = KeyHelper.generate_key
      user = {
        username: 'test',
        password: 'Psw0rd!',
        password_confirmation: 'Psw0rd!',
        public_key: key.public_key.to_s
      }
      expect(UserValidator.new.validate(user).to_a).to eq([
        'Password must be between least 8 characters and 128 characters long'
      ])
    end

    it 'should detect invalid rsa public keys' do
      user = {
        username: 'test',
        password: 'Passw0rd!',
        password_confirmation: 'Passw0rd!',
        public_key: 'not a valid key'
      }
      expect(UserValidator.new.validate(user).to_a).to eq([
        'Public key is not a valid RSA Public Key'
      ])
    end

    it 'should not accept illegal characters in username' do
      key = KeyHelper.generate_key
      user = {
        username: 'test?',
        password: 'Passw0rd!',
        password_confirmation: 'Passw0rd!',
        public_key: key.public_key.to_s
      }
      expect(UserValidator.new.validate(user).to_a).to eq([
        'Username must be only letters, numbers, "-" and "_"'
      ])
    end

    it 'should check the username is at least 4 characters long' do
      key = KeyHelper.generate_key
      user = {
        username: 'tes',
        password: 'Passw0rd!',
        password_confirmation: 'Passw0rd!',
        public_key: key.public_key.to_s
      }
      expect(UserValidator.new.validate(user).to_a).to eq([
        'Username must be between 4 and 30 characters'
      ])
    end

    it 'should check the username is no more than 30 characters long' do
      key = KeyHelper.generate_key
      user = {
        username: 'a' * 31,
        password: 'Passw0rd!',
        password_confirmation: 'Passw0rd!',
        public_key: key.public_key.to_s
      }
      expect(UserValidator.new.validate(user).to_a).to eq([
        'Username must be between 4 and 30 characters'
      ])
    end
  end
end

