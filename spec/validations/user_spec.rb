describe Duse::API::Validations::User do
  subject { Duse::API::Validations::User }

  context :password do
    it "prevents weak passwords" do
      user = OpenStruct.new(
        password: "password",
        password_confirmation: "password"
      )
      expect(subject.new(action: :create).validate(user).to_a).to eq(["Password too weak"])
    end

    it "accepts strong passwords" do
      user = OpenStruct.new(
        password: "Psw0rd!",
        password_confirmation: "Psw0rd!"
      )
      expect(subject.new(action: :create).validate(user).to_a).to eq([
        "Password must be between 8 and 128 characters long"
      ])
    end

    it "ignores the password check when not creating a user" do
      user = OpenStruct.new(
        password: "password",
        password_confirmation: "password"
      )
      expect(subject.new(action: :update).validate(user).to_a).to be_empty
    end
  end

  context :public_key do
    it "detects invalid rsa public keys" do
      user = OpenStruct.new(
        public_key: "not a valid key"
      )
      expect(subject.new.validate(user).to_a).to eq([
        "Public key is not a valid RSA Public Key"
      ])
    end

    it "accepts valid rsa public keys with 2048 bits" do
      user = OpenStruct.new(
        public_key: KeyHelper.generate_key.public_key.to_s
      )
      expect(subject.new.validate(user).to_a).to be_empty
    end
  end

  context :email do
    it "accepts correct email addresses" do
      user = OpenStruct.new(
        email: "test@example.org"
      )
      expect(subject.new.validate(user).to_a).to be_empty
    end

    it "checks the email is at least 3 characters" do
      user = OpenStruct.new(
        email: "a@",
      )
      expect(subject.new.validate(user).to_a).to eq [
        "Email must be between 3 and 128 characters long",
        "Email is not a valid email address"
      ]
    end

    it "ckecks the email is at most 128 characters" do
      user = OpenStruct.new(
        email: ("a"*128) + "@test.com",
      )
      expect(subject.new.validate(user).to_a).to eq [
        "Email must be between 3 and 128 characters long"
      ]
    end
  end

  context :username do
    it "accepts a valid username" do
      user = OpenStruct.new(
        username: "test"
      )

      expect(subject.new.validate(user)).to be_empty
    end

    it "does not accept illegal characters in username" do
      user = OpenStruct.new(
        username: "test?"
      )
      expect(subject.new.validate(user).to_a).to eq([
        "Username must be only letters, numbers, \"-\" and \"_\""
      ])
    end

    it "checks the username is at least 4 characters long" do
      user = OpenStruct.new(
        username: "tes"
      )
      expect(subject.new.validate(user).to_a).to eq([
        "Username must be between 4 and 30 characters long"
      ])
    end

    it "checks the username is no more than 30 characters long" do
      user = OpenStruct.new(
        username: "a" * 31
      )
      expect(subject.new.validate(user).to_a).to eq([
        "Username must be between 4 and 30 characters long"
      ])
    end
  end
end

