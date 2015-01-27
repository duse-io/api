require 'openssl'
require 'base64'

module Encryption
  module_function

  def encrypt(private_key, public_key, text)
    encrypted = public_key.public_encrypt text.force_encoding('ascii-8bit')
    signature = sign(private_key, encrypted)
    [encode(encrypted), signature]
  end

  def sign(private_key, text)
    encode(private_key.sign(digest, text))
  end

  def decrypt(private_key, text)
    private_key.private_decrypt(decode(text)).force_encoding('utf-8')
  end

  def verify(public_key, signature, encrypted)
    public_key.verify digest, decode(signature), decode(encrypted)
  end

  def digest
    OpenSSL::Digest::SHA256.new
  end

  def encode(plain_text)
    Base64.encode64(plain_text).encode('utf-8')
  end

  def decode(encoded_text)
    Base64.decode64 encoded_text.encode('ascii-8bit')
  end
end

