describe Duse::API::Validations::LengthBetween do
  subject { Duse::API::Validations::LengthBetween.new(subject_name: :test, min: 5, max: 7 ) }

  context "valid input" do
    it "responds with an empty array including the lower boundary" do
      expect(subject.validate("aaaaa")).to be_empty
    end

    it "responds with an empty array when the length is between min and max" do
      expect(subject.validate("aaaaaa")).to be_empty
    end

    it "responds with an empty array including the upper boundary" do
      expect(subject.validate("aaaaaaa")).to be_empty
    end

    it "does not validate when nil" do
      expect(subject.validate(nil)).to be_empty
    end

    it "does not validate when empty" do
      expect(subject.validate("")).to be_empty
    end
  end

  context "invalid input" do
    it "returns an array that contains an error message when lower than the boundary" do
      expect(subject.validate("a")).to eq [
        "test must be between 5 and 7 characters long"
      ]
    end

    it "returns an array that contains an error message when higher than the boundary" do
      expect(subject.validate("aaaaaaaa")).to eq [
        "test must be between 5 and 7 characters long"
      ]
    end

    it "creates the error messages based on the min, max, and subject_name options" do
      expect(
        Duse::API::Validations::LengthBetween.new(subject_name: :test_val, min: 1, max: 2).validate("aaa")
      ).to eq ["test_val must be between 1 and 2 characters long"]
    end
  end
end

