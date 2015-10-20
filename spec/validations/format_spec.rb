describe Duse::API::Validations::Format do
  subject { Duse::API::Validations::Format.new(subject_name: :test, format: /a+/) }

  context "valid input" do
    it "returns an empty array" do
      expect(subject.validate("aaaaa")).to be_empty
    end

    it "does not validate on nil" do
      expect(subject.validate(nil)).to be_empty
    end

    it "does not validate when empty" do
      expect(subject.validate("")).to be_empty
    end
  end

  context "invalid input" do
    it "rejects input that does not match the given regex" do
      expect(subject.validate("b")).not_to be_empty
    end

    it "returns an array that contains an error message" do
      expect(subject.validate("b")).to eq [
        "test contains illegal characters"
      ]
    end

    it "creates the error message based on the subject_name option" do
      expect(
        Duse::API::Validations::Format.new(subject_name: :test_val, format: /a+/).validate("b")
      ).to eq [
        "test_val contains illegal characters"
      ]
    end
  end
end

