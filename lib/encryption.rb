module Encryption
  module_function

  def encrypt(private_key, public_key, text)
    encrypted = public_key.public_encrypt text
    signature = private_key.sign digest, encrypted
    [encode(encrypted), encode(signature)]
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
