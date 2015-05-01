class UserValidator
  class PasswordValidator
    def validate(user)
      if !user.password.nil? && !user.password.length.between?(8, 128)
        user.errors[:base] << 'Password must be between least 8 characters and 128 characters long'
      end

      if !user.password.nil? && !is_password_complex_enough?(user.password)
        user.errors[:base] << 'Password too weak'
      end
    end

    private

    def is_password_complex_enough?(password)
      if (/.*[[:punct:]\W]+.*/ =~ password).nil? || # special chars
          (/.*[[:upper:]]+.*/  =~ password).nil? || # upper chars
          (/.*[[:lower:]]+.*/  =~ password).nil? || # lower chars
          (/.*\d+.*/           =~ password).nil?    # digits
        return false
      end
      true
    end
  end

  class UsernameValidator
    def validate(user)
      if !user.username.nil? && !user.username.length.between?(4, 30)
        user.errors[:base] << 'Username must be between 4 and 30 characters'
      end

      if !user.username.nil? && user.username !~ /[a-zA-Z0-9_-]+$/
        user.errors[:base] << 'Username must be only letters, numbers, "-" and "_"'
      end
    end
  end

  class EmailValidator
    def validate(user)
      if !user.email.nil? && user.email !~ /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
        user.errors[:base] << 'Email is not a valid email address'
      end

      if !user.email.nil? && user.email.length > 128
        user.errors[:base] << 'Email must not be longer than 128 characters'
      end
    end
  end

  class PublicKeyValidator
    def validate(user)
      if !user.public_key.nil? && !is_valid_public_key?(user.public_key)
        user.errors[:base] << 'Public key is not a valid RSA Public Key'
      end
      if !user.public_key.nil? && is_valid_public_key?(user.public_key) && key_size(user.public_key) < 2048
        user.errors[:base] << 'Public key size must be 2048 bit or larger'
      end
    end

    private

    def key_size(public_key)
      key = OpenSSL::PKey::RSA.new public_key
      key.n.num_bytes * 8
    end

    def is_valid_public_key?(public_key)
      key = OpenSSL::PKey::RSA.new public_key
      key.public?
    rescue OpenSSL::PKey::RSAError
      false
    end
  end

  class User
    include ActiveModel::Model

    attr_accessor :username, :password, :password_confirmation, :email, :public_key

    validate do |user|
      PasswordValidator.new.validate(user)
      UsernameValidator.new.validate(user)
      EmailValidator.new.validate(user)
      PublicKeyValidator.new.validate(user)
    end
  end

  def initialize(options = {})
    @options = options
  end

  def validate(user)
    user = User.new(user)
    user.valid?
    user.errors.full_messages
  end
end

