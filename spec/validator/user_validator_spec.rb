describe UserValidator do
  context :password do
    it 'should prevent weak passwords' do
      key = generate_key
      user = {
        username: 'test',
        password: 'password',
        password_confirmation: 'password',
        public_key: key.public_key.to_s
      }
      expect(UserValidator.new.validate(user).to_a).to eq(['Password too weak.'])
    end

    it 'should view "_" as a special character' do
      key = generate_key
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
      key = generate_key
      user = {
        username: 'test',
        password: 'Psw0rd!',
        password_confirmation: 'Psw0rd!',
        public_key: key.public_key.to_s
      }
      expect(UserValidator.new.validate(user).to_a).to eq([
        'Password must be at least 8 characters long'
      ])
    end

    it 'should check that password confirmation equals password' do
      key = generate_key
      user = {
        username: 'test',
        password: 'Passw0rd!!',
        password_confirmation: 'Passw0rd!',
        public_key: key.public_key.to_s
      }
      expect(UserValidator.new.validate(user).to_a).to eq([
        'Password and password confirmation do not match'
      ])
    end
  end
end
