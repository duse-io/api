describe SecretJSON do

  before :each do
    DatabaseCleaner.start
  end

  after :each do
    DatabaseCleaner.clean
  end

  it 'should validate secrets correctly' do
    server = Duse::Models::Server.get
    user1  = create_default_user username: 'test1'
    user2  = create_default_user username: 'test2'

    json = SecretJSON.new({
      title: 'My secret',
      parts: [
        [
          { user_id: server.id, content: 'content', signature: 'signature' },
          { user_id: user1.id,  content: 'content', signature: 'signature' },
          { user_id: user2.id,  content: 'content', signature: 'signature' }
        ]
      ]
    })

    json.validate!(current_user: user1)
  end
end
