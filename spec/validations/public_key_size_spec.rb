describe Duse::API::Validations::PublicKeySize do
  subject { Duse::API::Validations::PublicKeySize.new(subject_name: :test) }

  context "2048 bit public key" do
    let(:public_key) { OpenSSL::PKey::RSA.generate(2048).public_key.to_s }

    it "accepts the input" do
      expect(subject.validate(public_key)).to be_empty
    end
  end

  context "1024 bit public key" do
    let(:public_key) { OpenSSL::PKey::RSA.generate(1024).public_key.to_s }

    it "errors that the key is invalid" do
      expect(subject.validate(public_key)).to eq [
        "Public key size must be 2048 bit or larger"
      ]
    end
  end

  context "invalid public key" do
    let(:public_key) { "abc" }

    it "does not validate" do
      expect(subject.validate(public_key)).to be_empty
    end
  end
end

