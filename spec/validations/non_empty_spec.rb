describe Duse::API::Validations::NonEmpty do
  subject { Duse::API::Validations::NonEmpty.new(subject_name: :test) }

  context "valid input" do
    it "does not validate on nil" do
      expect(subject.validate(nil)).to be_empty
    end

    it "works on a string" do
      expect(subject.validate("a")).to be_empty
    end

    it "works on an array" do
      expect(subject.validate(["a"])).to be_empty
    end
  end

  context "invalid input" do
    it "rejects input that is empty" do
      expect(subject.validate("")).not_to be_empty
    end

    it "returns an array that contains an error message" do
      expect(subject.validate("")).to eq [
        "test must not be blank"
      ]
    end

    it "creates the error message based on the subject_name option" do
      expect(
        Duse::API::Validations::NonEmpty.new(subject_name: :test_val).validate("")
      ).to eq [
        "test_val must not be blank"
      ]
    end
  end
end

