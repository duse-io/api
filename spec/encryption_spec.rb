describe Encryption do
  it 'correctly verifies a signed encrypted text' do
    key1 = generate_key
    key2 = generate_key
    encrypted, signature = Encryption.encrypt key1, key2.public_key, 'text'
    expect(Encryption.verify key1.public_key, signature, encrypted).to be true
  end

  it 'correctly decrypts a previously encrypted text' do
    key1 = generate_key
    key2 = generate_key
    encrypted, signature = Encryption.encrypt key1, key2.public_key, 'text'
    expect(Encryption.decrypt key2, encrypted).to eq 'text'
  end
end
