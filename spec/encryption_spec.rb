describe Encryption do
  it '' do
    key1 = generate_key
    key2 = generate_key
    encrypted, signature = Encryption.encrypt key1, key2.public_key, 'text'
    expect(Encryption.verify key1.public_key, signature, encrypted).to be true
  end
end
