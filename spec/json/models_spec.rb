describe SecretJSON do
  include JsonFactory

  before :each do
    DatabaseCleaner.start
  end

  after :each do
    DatabaseCleaner.clean
  end

  it 'should validate secrets correctly' do
    json = SecretJSON.new(default_secret)

    json.validate!(current_user: @user1)
  end
end

