describe Duse::Models::Share do

  before :each do
    DatabaseCleaner.start
  end

  after :each do
    DatabaseCleaner.clean
  end

  it 'a correctly encrypted and signed share should not raise errors' do
    secret = create(:secret)
    expect(secret.valid?).to be true
  end
end

