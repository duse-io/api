require 'duse/api/validations/validation'
require 'duse/api/validations/model_validation'
require 'duse/api/validations/multi_validation'
require 'duse/api/validations/format_validation'
require 'duse/api/validations/max_length_validation'
require 'duse/api/validations/length_between_validation'

class PasswordComplexityValidation < Validation
  def validate(password)
    if (/.*[[:punct:]\W]+.*/ =~ password).nil? || # special chars
        (/.*[[:upper:]]+.*/  =~ password).nil? || # upper chars
        (/.*[[:lower:]]+.*/  =~ password).nil? || # lower chars
        (/.*\d+.*/           =~ password).nil?    # digits
      return ['Password too weak']
    end
    []
  end
end

class PublicKeyValidityAndSizeValidation < Validation
  def validate(public_key)
    errors = []
    if !public_key.nil? && !is_valid_public_key?(public_key)
      errors << 'Public key is not a valid RSA Public Key'
    end
    if !public_key.nil? && is_valid_public_key?(public_key) && key_size(public_key) < 2048
      errors << 'Public key size must be 2048 bit or larger'
    end
    errors
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

class UserValidation < ModelValidation
  class PasswordValidation < MultiValidation
    validate LengthBetweenValidation, min: 8, max: 128
    validate PasswordComplexityValidation
  end

  class UsernameValidation < MultiValidation
    validate LengthBetweenValidation, min: 4, max: 30
    validate FormatValidation, format: /[a-zA-Z0-9_-]+$/, msg: 'Username must be only letters, numbers, "-" and "_"'
  end

  class EmailValidation < MultiValidation
    validate MaxLengthValidation, max: 128
    validate FormatValidation, format: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/, msg: 'Email is not a valid email address'
  end

  class PublicKeyValidation < MultiValidation
    validate PublicKeyValidityAndSizeValidation
  end

  validate PasswordValidation, :password, on: :create
  validate UsernameValidation, :username
  validate EmailValidation, :email
  validate PublicKeyValidation, :public_key
end

