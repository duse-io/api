RSpec.describe Duse::API::Validations::Secret do
  subject { Duse::API::Validations::Secret.new }

  describe :title do
    context 'valid' do
      it 'returns an empty array' do
        expect(subject.validate(OpenStruct.new(title: 'test'))).to be_empty
      end
    end

    context 'empty' do
      it 'does not accept' do
        expect(subject.validate(OpenStruct.new(title: ''))).to eq [
          'Title must not be blank'
        ]
      end
    end

    context '81 characters' do
      it 'does not accept' do
        expect(subject.validate(OpenStruct.new(title: 'a'*81))).to eq [
          'Title must be between 1 and 80 characters long'
        ]
      end
    end
  end

  describe :cipher_text do
    context 'valid' do
      it 'returns an empty array' do
        secret = OpenStruct.new(cipher_text: ('a'*6)+'==')
        expect(subject.validate(secret)).to be_empty
      end
    end

    context 'empty' do
      it 'does not accept' do
        expect(subject.validate(OpenStruct.new(cipher_text: ''))).to eq [
          'Cipher must not be blank'
        ]
      end
    end

    context 'not base64' do
      it 'does not accept' do
        expect(subject.validate(OpenStruct.new(cipher_text: '??????=='))).to eq [
          'Cipher is expected to be base64 encoded'
        ]
      end
    end

    context 'too long' do
      it 'does not accept' do
        expect(subject.validate(OpenStruct.new(cipher_text: ('a'*5002)+'=='))).to eq [
          'Secret is too long'
        ]
      end
    end
  end

  describe :folder_id do
    it 'checks the folder exists' do
      allow(Duse::API::Models::Folder).to receive(:exists?).and_return(false)

      expect(subject.validate(OpenStruct.new(folder_id: 1))).to eq [
        'Folder does not exist'
      ]
    end
  end

  describe :shares do
    include JsonFactory

    it 'ensures each user only has one share' do
      private_key = KeyHelper.generate_key
      current_user = Duse::API::Models::User.new(id: 2, public_key: private_key.public_key)
      server_user = Duse::API::Models::User.new(id: 1, public_key: KeyHelper.generate_key.public_key)
      allow(Duse::API::Models::User).to receive(:exists?).and_return(true)
      allow(Duse::API::Models::User).to receive(:find) { |id| [server_user, current_user].fetch(id-1) }
      secret = OpenStruct.new(shares: [
        share(1, 'share', private_key, server_user.public_key),
        share(2, 'share', private_key, current_user.public_key),
        share(2, 'share', private_key, current_user.public_key)
      ])
      validator = Duse::API::Validations::Secret.new(current_user: current_user, server_user: server_user)

      expect(validator.validate(secret)).to eq([
        'Each user must only have one share'
      ])
    end

    it 'ensures the shares include a share for the current user' do
      private_key = KeyHelper.generate_key
      current_user = Duse::API::Models::User.new(id: 2, public_key: private_key.public_key)
      server_user = Duse::API::Models::User.new(id: 1, public_key: KeyHelper.generate_key.public_key)
      allow(Duse::API::Models::User).to receive(:exists?).and_return(true)
      allow(Duse::API::Models::User).to receive(:find) { |id| [server_user, current_user].fetch(id-1) }
      secret = OpenStruct.new(shares: [share(1, 'share', private_key, server_user.public_key)])
      validator = Duse::API::Validations::Secret.new(current_user: current_user, server_user: server_user)

      expect(validator.validate(secret)).to eq([
        'Shares for your user must be present'
      ])
    end

    it 'ensures the shares include a share for the server user' do
      private_key = KeyHelper.generate_key
      current_user = Duse::API::Models::User.new(id: 2, public_key: private_key.public_key)
      server_user = Duse::API::Models::User.new(id: 1, public_key: KeyHelper.generate_key.public_key)
      allow(Duse::API::Models::User).to receive(:exists?).and_return(true)
      allow(Duse::API::Models::User).to receive(:find) { |id| [server_user, current_user].fetch(id-1) }
      secret = OpenStruct.new(shares: [share(2, 'share', private_key, server_user.public_key)])
      validator = Duse::API::Validations::Secret.new(current_user: current_user, server_user: server_user)

      expect(validator.validate(secret)).to eq([
        'Shares for the server must be present'
      ])
    end

    it 'ensures the shares user\'s exist' do
      private_key = KeyHelper.generate_key
      current_user = Duse::API::Models::User.new(id: 2, public_key: private_key.public_key)
      server_user = Duse::API::Models::User.new(id: 1, public_key: KeyHelper.generate_key.public_key)
      allow(Duse::API::Models::User).to receive(:exists?) { |id| !(id == 3) }
      allow(Duse::API::Models::User).to receive(:find) { |id| [server_user, current_user].fetch(id-1) }
      secret = OpenStruct.new(shares: [
        share(1, 'share', private_key, server_user.public_key),
        share(2, 'share', private_key, current_user.public_key),
        share(3, 'share', private_key, current_user.public_key)
      ])
      validator = Duse::API::Validations::Secret.new(current_user: current_user, server_user: server_user)

      expect(validator.validate(secret)).to eq([
        'One or more of the provided users do not exist'
      ])
    end

    it 'ensures the shares content length matches the supposably used public key length' do
      private_key = KeyHelper.generate_key
      current_user = Duse::API::Models::User.new(id: 2, public_key: private_key.public_key)
      server_user = Duse::API::Models::User.new(id: 1, public_key: KeyHelper.generate_key.public_key)
      allow(Duse::API::Models::User).to receive(:exists?) { |id| !(id == 3) }
      allow(Duse::API::Models::User).to receive(:find) { |id| [server_user, current_user].fetch(id-1) }
      secret = OpenStruct.new(shares: [
        share(1, 'share', private_key, server_user.public_key),
        {
          user_id: 2,
          content: Encryption.encode('a'),
          signature: Encryption.sign(private_key, 'a')
        }
      ])
      validator = Duse::API::Validations::Secret.new(current_user: current_user, server_user: server_user)

      expect(validator.validate(secret)).to eq([
        'Public key and share content lengths do not match'
      ])
    end

    it 'verifies the shares signature' do
      private_key = KeyHelper.generate_key
      current_user = Duse::API::Models::User.new(id: 2, public_key: private_key.public_key)
      server_user = Duse::API::Models::User.new(id: 1, public_key: KeyHelper.generate_key.public_key)
      allow(Duse::API::Models::User).to receive(:exists?) { |id| !(id == 3) }
      allow(Duse::API::Models::User).to receive(:find) { |id| [server_user, current_user].fetch(id-1) }
      secret = OpenStruct.new(shares: [
        share(1, 'share', private_key, server_user.public_key),
        share(2, 'share', private_key, current_user.public_key).merge(signature: 'a')
      ])
      validator = Duse::API::Validations::Secret.new(current_user: current_user, server_user: server_user)

      expect(validator.validate(secret)).to eq([
        'Authenticity could not be verified. Wrong signature.'
      ])
    end
  end
end

