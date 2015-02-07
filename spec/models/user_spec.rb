describe Duse::Models::User do

  before :each do
    DatabaseCleaner.start
  end

  after :each do
    DatabaseCleaner.clean
  end

  it 'should not be valid if a user with the same username already exists' do
    Duse::Models::User.create(username: 'test', password: 'test')
    user = Duse::Models::User.new(username: 'test', password: 'test')
    
    expect(user.valid?).to be false
  end
end

