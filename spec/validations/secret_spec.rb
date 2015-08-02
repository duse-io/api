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
    context 'TODO'
  end
end

