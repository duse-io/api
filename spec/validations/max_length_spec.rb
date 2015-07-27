describe Duse::API::Validations::MaxLength do
  subject { Duse::API::Validations::MaxLength.new(subject_name: :test, max: 7 ) }

  context 'valid input' do
    it 'responds with an empty array when the length is between min and max' do
      expect(subject.validate('aaaaaa')).to be_empty
    end

    it 'responds with an empty array including the upper boundary' do
      expect(subject.validate('aaaaaaa')).to be_empty
    end

    it 'does not validate when nil' do
      expect(subject.validate(nil)).to be_empty
    end

    it 'does not validate when empty' do
      expect(subject.validate('')).to be_empty
    end
  end

  context 'invalid input' do
    it 'returns an array that contains an error message when higher than the boundary' do
      expect(subject.validate('aaaaaaaa')).to eq [
        'test must be at most 7 characters long'
      ]
    end

    it 'creates the error messages based on the max and subject_name options' do
      expect(
        Duse::API::Validations::MaxLength.new(subject_name: :test_val, max: 2).validate('aaa')
      ).to eq ['test_val must be at most 2 characters long']
    end
  end
end

