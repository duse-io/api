module KeyHelper
  extend self

  def generate_public_key(size = 2048)
    generate_key(size).public_key.to_s
  end

  def generate_key(size = 2048)
    OpenSSL::PKey::RSA.generate(size)
  end
end

