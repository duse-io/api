require 'duse/api/validations/base'

module Duse
  module API
    module Validations
      class PublicKeyValidityAndSize < Base
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
    end
  end
end

