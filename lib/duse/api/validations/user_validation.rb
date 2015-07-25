require 'duse/api/validations/validation'
require 'duse/api/validations/model_validation'
require 'duse/api/validations/multi_validation'
require 'duse/api/validations/format_validation'
require 'duse/api/validations/max_length_validation'
require 'duse/api/validations/length_between_validation'
require 'duse/api/validations/password_complexity_validation'
require 'duse/api/validations/public_key_validity_and_size_validation'

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

