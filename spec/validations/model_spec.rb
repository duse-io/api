describe Duse::API::Validations::Model do
  def multi_validation(*args)
    multi_validation = Class.new Duse::API::Validations::Multi
    args.prepend(Duse::API::Validations::NonEmpty)
    multi_validation.validate *args
    multi_validation
  end

  context "always validate all specified validations" do
    it "validates and collects error messages from all nested validations" do
      model_validation = Class.new Duse::API::Validations::Model
      model_validation.validate multi_validation(subject_name: "Name"), :arg1
      model_validation.validate multi_validation(subject_name: "Password"), :arg2

      model = OpenStruct.new(
        arg1: "",
        arg2: ""
      )
      expect(model_validation.new.validate(model)).to eq [
        "Name must not be blank",
        "Password must not be blank"
      ]
    end

    it "sets the subject_name to a default when constructing a validation" do
      model_validation = Class.new Duse::API::Validations::Model
      model_validation.validate multi_validation, :name

      model = OpenStruct.new(
        name: ""
      )
      expect(model_validation.new.validate(model)).to eq ["Name must not be blank"]
    end
  end

  context "on action specified" do
    subject {
      model_validation = Class.new Duse::API::Validations::Model
      model_validation.validate multi_validation, :arg1, on: :create
      model_validation
    }

    it "ignores the validation on other actions" do
      model = OpenStruct.new(
        arg1: ""
      )

      expect(subject.new(action: :update).validate(model)).to be_empty
    end

    it "validates on the specified action" do
      model = OpenStruct.new(
        arg1: ""
      )

      expect(subject.new(action: :create).validate(model)).to eq [
        "Arg1 must not be blank"
      ]
    end
  end
end

