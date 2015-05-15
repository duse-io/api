describe Duse::Models::Share do
  it 'a correctly encrypted and signed share should not raise errors' do
    secret = create(:secret)
    expect(secret.valid?).to be true
  end
end

