require "duse/api/validations/single"

module Duse
  module API
    module Validations
      class PublicKeyValidity
        include Single

        def invalid?(public_key)
          !public_key.nil? && !is_valid?(public_key)
        end

        def error_msg
          "Public key is not a valid RSA Public Key"
        end

        def is_valid?(public_key)
          key = OpenSSL::PKey::RSA.new public_key
          key.public?
        rescue OpenSSL::PKey::RSAError
          false
        end
      end
    end
  end
end

