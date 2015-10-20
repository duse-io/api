describe Duse::API::Validations::Multi do
  it "validates with all given validations" do
    multi_validation = Class.new Duse::API::Validations::Multi
    multi_validation.validate Duse::API::Validations::MaxLength, max: 2
    multi_validation.validate Duse::API::Validations::Format, format: /b+/

    model = OpenStruct.new(
      name: "aaa"
    )
    expect(multi_validation.new(:name, subject_name: "Name").validate(model)).to eq [
      "Name must be at most 2 characters long",
      "Name contains illegal characters"
    ]
  end
end

