require 'dm-core'
require 'openssl'

module DataMapper
  class Property
    class RSAKey < DataMapper::Property::Text
      def load(value)
        return nil if value.nil?
        return value if value.is_a? OpenSSL::PKey::RSA
        begin
          OpenSSL::PKey::RSA.new(value)
        rescue OpenSSL::PKey::RSAError
          value
        end
      end

      def dump(value)
        return nil if value.nil?
        return value if value.is_a? String
        value.to_s
      end

      def typecast(value)
        load(value)
      end

      def custom?
        true
      end
    end # class RSAKey
  end # class Property
end # module DataMapper
