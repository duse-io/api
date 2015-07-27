describe Duse::API::Validations::ModelExists do
  subject {
    model_class_mock = Class.new do
      def self.exists?(value)
        value == 1
      end
    end
    Duse::API::Validations::ModelExists.new(subject_name: :test, model_class: model_class_mock)
  }

  context 'valid input' do
    it 'responds with an empty array when the specified model exists' do
      expect(subject.validate(1)).to be_empty
    end

    it 'does not validate when nil' do
      expect(subject.validate(nil)).to be_empty
    end
  end

  context 'invalid input' do
    it 'returns an array that contains an error message when the model does not exist' do
      expect(subject.validate(2)).to eq [
        'test does not exist'
      ]
    end

    it 'creates the error messages based on the subject_name options' do
      model_class_mock = Class.new do
        def self.exists?(value)
          false
        end
      end
      expect(
        Duse::API::Validations::ModelExists.new(subject_name: :test_val, model_class: model_class_mock).validate(2)
      ).to eq ['test_val does not exist']
    end
  end
end

