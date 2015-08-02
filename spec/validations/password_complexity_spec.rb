describe Duse::API::Validations::PasswordComplexity do
  context 'password has special characters, upper case, lower case and digits' do
    it 'accepts the password' do
      expect(Duse::API::Validations::PasswordComplexity.new.validate('Passw0rd!')).to be_empty
    end
  end

  context 'password does not include a special char' do
    it 'accepts the password' do
      expect(Duse::API::Validations::PasswordComplexity.new.validate('Passw0rd')).to eq [
        'Password too weak'
      ]
    end
  end

  context 'password does not include upper case' do
    it 'accepts the password' do
      expect(Duse::API::Validations::PasswordComplexity.new.validate('passw0rd!')).to eq [
        'Password too weak'
      ]
    end
  end

  context 'password does not include a lower case' do
    it 'accepts the password' do
      expect(Duse::API::Validations::PasswordComplexity.new.validate('PASSW0RD!')).to eq [
        'Password too weak'
      ]
    end
  end

  context 'password does not include digits' do
    it 'accepts the password' do
      expect(Duse::API::Validations::PasswordComplexity.new.validate('Password!')).to eq [
        'Password too weak'
      ]
    end
  end
end

