require "duse/api/validations/single"
require "duse/api/validations/public_key_validity"

module Duse
  module API
    module Validations
      class PublicKeySize
        include Single

        def invalid?(public_key)
          !public_key.nil? && PublicKeyValidity.new.is_valid?(public_key) && key_size(public_key) < 2048
        end

        def error_msg
          "Public key size must be 2048 bit or larger"
        end

        def key_size(public_key)
          key = OpenSSL::PKey::RSA.new public_key
          key.n.num_bytes * 8
        end
      end
    end
  end
end

