describe Encryption do
  it 'signature and encrypted text are utf-8 encoded' do
    key = generate_key
    encrypted, signature = Encryption.encrypt key, key.public_key, 'text'
    expect(encrypted.encoding).to eq Encoding::UTF_8
    expect(signature.encoding).to eq Encoding::UTF_8
  end

  it 'correctly verifies a signed encrypted text' do
    key1 = generate_key
    key2 = generate_key
    encrypted, signature = Encryption.encrypt key1, key2.public_key, 'text'
    expect(Encryption.verify key1.public_key, signature, encrypted).to be true
  end

  it 'correctly decrypts a previously encrypted text' do
    key1 = generate_key
    key2 = generate_key
    encrypted, _ = Encryption.encrypt key1, key2.public_key, 'text'
    expect(Encryption.decrypt key2, encrypted).to eq 'text'
  end
end

