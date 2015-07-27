require 'duse/api/validations/model'
require 'duse/api/validations/multi'
require 'duse/api/validations/format'
require 'duse/api/validations/max_length'
require 'duse/api/validations/length_between'
require 'duse/api/validations/password_complexity'
require 'duse/api/validations/public_key_validity'
require 'duse/api/validations/public_key_size'

module Duse
  module API
    module Validations
      class User < Model
        class Password < Multi
          validate LengthBetween, min: 8, max: 128
          validate PasswordComplexity
        end

        class Username < Multi
          validate LengthBetween, min: 4, max: 30
          validate Format, format: /[a-zA-Z0-9_-]+$/, msg: 'Username must be only letters, numbers, "-" and "_"'
        end

        class Email < Multi
          validate MaxLength, max: 128
          validate Format, format: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/, msg: 'Email is not a valid email address'
        end

        class PublicKey < Multi
          validate PublicKeyValidity
          validate PublicKeySize
        end

        validate Password, :password, on: :create
        validate Username, :username
        validate Email, :email
        validate PublicKey, :public_key
      end
    end
  end
end

