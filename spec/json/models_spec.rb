describe SecretJSON do
  it 'should validate secrets correctly' do
    hash = {
      title: 'My secret',
      required: 2,
      parts: [
        [
          { user_id: 'server', content: 'content', signature: 'signature' },
          { user_id: 'me',     content: 'content', signature: 'signature' },
          { user_id: 3,        content: 'content', signature: 'signature' }
        ]
      ]
    }
    json = SecretJSON.new hash

    expect(json.valid?).to be true
    expect(json.errors).to eq Set.new
  end
end
