RSpec.describe Duse::API::Validations::Folder do
  subject { Duse::API::Validations::Folder.new }

  describe :name do
    context "folder name: test" do
      it "returns an empty array" do
        folder = OpenStruct.new(name: "test")
        expect(subject.validate(folder)).to be_empty
      end
    end

    context "folder name empty" do
      it "returns an empty array" do
        folder = OpenStruct.new(name: "test")
        expect(subject.validate(folder)).to be_empty
      end
    end

    context "folder name contains questionmark" do
      it "returns an empty array" do
        folder = OpenStruct.new(name: "test?")
        expect(subject.validate(folder)).to eq [
          "Folder name contains illegal characters"
        ]
      end
    end

    context "folder name 51 characters" do
      it "returns an empty array" do
        folder = OpenStruct.new(name: "a"*51)
        expect(subject.validate(folder)).to eq [
          "Folder name must be between 1 and 50 characters long"
        ]
      end
    end
  end
end

